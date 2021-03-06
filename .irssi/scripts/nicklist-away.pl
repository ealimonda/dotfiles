# for documentation: see http://wouter.coekaerts.be/site/irssi/nicklist

use Irssi;
use strict;
use IO::Handle;                 # for (auto)flush
use Fcntl;                      # for sysopen

use Data::Dumper;

our $VERSION = '0.5.0';
our %IRSSI = (
          authors     => 'Wouter Coekaerts, shabble',
          contact     => 'coekie@irssi.org, shabble+irssi@metavore.org',
          name        => 'nicklist',
          description => 'draws a nicklist to another terminal, '
                       . 'or at the right of your irssi in the same terminal',
          license     => 'GPLv2',
          url         => 'http://wouter.coekaerts.be/irssi, '
                       . 'https://github.com/shabble/irssi-scripts'
                       . '/blob/master/fixery/nicklist.pl',
          changed     => '10/10/2011'
         );

sub cmd_help {
	print ( <<EOF
Commands:
NICKLIST HELP
NICKLIST SCROLL <number of lines>
NICKLIST SCREEN
NICKLIST FIFO
NICKLIST OFF
NICKLIST UPDATE

For help see: http://wouter.coekaerts.be/site/irssi/nicklist

in short:

1. FIFO MODE
- in irssi: /NICKLIST FIFO (only the first time, to create the fifo)
- in a shell, in a window where you want the nicklist: cat ~/.irssi/nicklistfifo
- back in irssi:
    /SET nicklist_heigth <height of nicklist>
    /SET nicklist_width <width of nicklist>
    /NICKLIST FIFO

2. SCREEN MODE
- start irssi inside screen ("screen irssi")
- /NICKLIST SCREEN
EOF
          );
}
sub MODE_OFF    () { 0 }
sub MODE_SCREEN () { 1 }
sub MODE_FIFO   () { 2 }

my $prev_lines = 0;             # number of lines in previous written nicklist
my $scroll_pos = 0;             # scrolling position
my $cursor_line;                # line the cursor is currently on
my ($OFF, $SCREEN, $FIFO) = (0,1,2); # modes
my $mode = MODE_OFF;                     # current mode
my $need_redraw = 0;                 # nicklist needs redrawing
my $need_wholist = 0;                # nicklist needs updating via /who
my $screen_resizing = 0;             # terminal is being resized
my $active_channel;                  # (REC)
my $channel_refresh = undef;
my $active_wholist = 0;


# TODO: have this use isupport('PREFIX') where supported to check mappings.
my $server_prefix_mapping
  = {
     '~' => { priority => 1, sigil => '~', mode => 'q', name => 'owner'  },
     '&' => { priority => 2, sigil => '&', mode => 'a', name => 'admin'  },
     '@' => { priority => 3, sigil => '@', mode => 'o', name => 'op'     },
     '%' => { priority => 4, sigil => '%', mode => 'h', name => 'halfop' },
     '+' => { priority => 5, sigil => '+', mode => 'v', name => 'voice'  },
     ''  => { priority => 6, sigil => '',  mode => '',  name => 'normal' },
    };


# order the sigils by priority (lowest = first) from the table above.
my @sigil_priorities = map  { $_->{sigil} }
                       sort { $a->{priority} <=> $b->{priority} }
                       values %$server_prefix_mapping;


my $sigil_cache = {};

my $DEBUG = 0;

sub _debug {
    my ($msg) = @_;
    Irssi::print($msg) if $DEBUG;
}


sub _select_prefix_umode {
    my ($nick) = @_;
    my $prefixes = { map { $_ => 1 } split '', $nick->{prefixes} };

    # first check for each of the prefix sigils in given order of precedence.
    for my $sigil_priority (@sigil_priorities) {
        if (exists $prefixes->{$sigil_priority}) {
            return $server_prefix_mapping->{$sigil_priority};
        }
    }
    # check other properties
    if ($nick->{op}) {
        return $server_prefix_mapping->{'@'};
    } elsif ($nick->{halfop}) {
        return $server_prefix_mapping->{'%'};
    } elsif ($nick->{voice}) {
        return $server_prefix_mapping->{'+'};
    } else {
        return $server_prefix_mapping->{''};
    }

}

# array of hashes, containing the internal nicklist of the active channel
my @nicklist = ();
# nick => realnick
# mode =>
# status =>
my ($STATUS_NORMAL, $STATUS_JOINING, $STATUS_PARTING,
    $STATUS_QUITING, $STATUS_KICKED, $STATUS_SPLIT) = (0,1,2,3,4,5);
# text => text to be printed
# cmp => text used to compare (sort) nicks


# 'cached' settings
my ($screen_prefix, $irssi_width,  $height, $nicklist_width);

sub read_settings {

    $DEBUG = Irssi::settings_get_bool('nicklist_debug');

	$screen_prefix = Irssi::settings_get_str('nicklist_screen_prefix');
    $screen_prefix =~ s/\\e/\033/g;


    foreach my $umode_prefix (values %$server_prefix_mapping) {
        my $umode_name = $umode_prefix->{name};
        my $setting_name = 'nicklist_prefix_mode_' . $umode_name;
        my $value = Irssi::settings_get_str($setting_name);

        $value = '' unless defined $value;
        $value =~ s/\\e/\x1b/g;

        $sigil_cache->{$umode_name} = $value;
    }

	if ($mode != MODE_SCREEN) {
		$height = Irssi::settings_get_int('nicklist_height');
	}
	my $new_nicklist_width = Irssi::settings_get_int('nicklist_width');
	if ($new_nicklist_width != $nicklist_width && $mode == MODE_SCREEN) {
		sig_terminal_resized();
	}
	$nicklist_width = $new_nicklist_width;
}

sub update {
	read_settings();
	make_nicklist();
}

##################
##### OUTPUT #####
##################

### off ###

sub cmd_off {
	if ($mode == MODE_SCREEN) {
		screen_stop();
	} elsif ($mode == MODE_FIFO) {
		fifo_stop();
	}
}

### fifo ###

sub cmd_fifo_start {
	read_settings();
	my $path = Irssi::settings_get_str('nicklist_fifo_path');
	unless (-p $path) {         # not a pipe
	    if (-e _) {             # but a something else
	        die "$0: $path exists and is not a pipe, please remove it\n";
	    } else {
	        require POSIX;
	        POSIX::mkfifo($path, 0666) or die "can\'t mkfifo $path: $!";
            Irssi::print("Fifo created. Start reading it (\"cat $path\") and try again.");
            return;
	    }
	}
	if (!sysopen(FIFO, $path, O_WRONLY | O_NONBLOCK)) { # or die "can't write $path: $!";
		Irssi::print("Couldn\'t write to the fifo ($!). Please start reading the fifo (\"cat $path\") and try again.");
		return;
	}
	FIFO->autoflush(1);
	print FIFO "\033[2J\033[1;1H"; # erase screen & jump to 0,0
	$cursor_line = 0;
	if ($mode == MODE_SCREEN) {
		screen_stop();
	}
	$mode = MODE_FIFO;
	make_nicklist();
	$channel_refresh = Irssi::timeout_add(5*60*1000, \&channel_refresh, []);
}

sub fifo_stop {
	close FIFO;
	$mode = MODE_OFF;
	Irssi::print("Fifo closed.");
	Irssi::timeout_remove($channel_refresh) if $channel_refresh;
}

### screen ###

sub cmd_screen_start {
	if (!defined($ENV{STY})) {
		Irssi::print 'screen not detected, screen mode only works inside screen';
		return;
	}
	read_settings();
	if ($mode == MODE_SCREEN) {
        return;
    }
	if ($mode == MODE_FIFO) {
		fifo_stop();
	}
	$mode = MODE_SCREEN;
	Irssi::signal_add_last('gui print text finished', 'sig_gui_print_text_finished');
	Irssi::signal_add_last('gui page scrolled',       'sig_page_scrolled');
	Irssi::signal_add('terminal resized',             'sig_terminal_resized');
	screen_size();
	make_nicklist();
	$channel_refresh = Irssi::timeout_add(5*60*1000, \&channel_refresh, []);
}

sub screen_stop {
	$mode = MODE_OFF;
	Irssi::signal_remove('gui print text finished', 'sig_gui_print_text_finished');
	Irssi::signal_remove('gui page scrolled',       'sig_page_scrolled');
	Irssi::signal_remove('terminal resized',        'sig_terminal_resized');
	system 'screen -x '.$ENV{STY}.' -X fit';
	Irssi::timeout_remove($channel_refresh) if $channel_refresh;
}

sub screen_size {
	if ($mode != MODE_SCREEN) {
		return;
	}
	$screen_resizing = 1;
	# fit screen
	system 'screen -x '.$ENV{STY}.' -X fit';
	# get size (from perldoc -q size)
	my ($winsize, $row, $col, $xpixel, $ypixel);
	eval 'use Term::ReadKey; ($col, $row, $xpixel, $ypixel) = GetTerminalSize';
	#	require Term::ReadKey 'GetTerminalSize';
	#	($col, $row, $xpixel, $ypixel) = Term::ReadKey::GetTerminalSize;
	#};
	if ($@) {                   # no Term::ReadKey, try the ugly way
		eval {
			require 'sys/ioctl.ph';
			# without this reloading doesn't work. workaround for some unknown bug
			do 'asm/ioctls.ph';
		};

		# ugly way not working, let's try something uglier, the dg-hack(tm)
		# (constant for linux only?)
		if ($@) {
            no strict 'refs'; *TIOCGWINSZ = sub { return 0x5413 };
        }

		unless (defined &TIOCGWINSZ) {
			die "Term::ReadKey not found, and ioctl 'workaround' failed. "
              . "Install the Term::ReadKey perl module to use screen mode.\n";
		}
		open my $tty, "+</dev/tty" or die "No tty: $!";
		unless (ioctl($tty, &TIOCGWINSZ, $winsize='')) {
			die "Term::ReadKey not found, and ioctl 'workaround' failed ($!)."
              . " Install the Term::ReadKey perl module to use screen mode.\n";
		}
		close $tty;
		($row, $col, $xpixel, $ypixel) = unpack('S4', $winsize);
	}

	# set screen width
	$irssi_width = $col - $nicklist_width - 1;
	$height = $row - 1;

	# on some recent systems, "screen -X fit; screen -X width -w 50" doesn't
	# work, needs a sleep in between the 2 commands so we wait a second before
	# setting the width
	Irssi::timeout_add_once
      (1000, sub {
           my ($new_irssi_width) = @_;
           system 'screen -x '.$ENV{STY}.' -X width -w ' . $new_irssi_width;
           # and then we wait another second for the resizing, and then redraw.
           Irssi::timeout_add_once(1000, sub {$screen_resizing = 0; redraw()}, []);
       }, $irssi_width);
}

sub sig_terminal_resized {
	if ($screen_resizing) {
		return;
	}
	$screen_resizing = 1;
	Irssi::timeout_add_once(1000, \&screen_size, []);
}


### both ###

sub nicklist_write_start {
	if ($mode == MODE_SCREEN) {
		print STDERR "\033P\033[s\033\\"; # save cursor
	}
}

sub nicklist_write_end {
	if ($mode == MODE_SCREEN) {
		print STDERR "\033P\033[u\033\\"; # restore cursor
	}
}

sub nicklist_write_line {
	my ($line, $data) = @_;

	if ($mode == MODE_SCREEN) {
		print STDERR "\033P\033[" . ($line+1) . ';'. ($irssi_width+1) .'H'. $screen_prefix . $data . "\033\\";
	} elsif ($mode == MODE_FIFO) {
		$data = "\033[m$data";  # reset color
		if ($line == $cursor_line+1) {
			$data = "\n$data";  # next line
		} elsif ($line == $cursor_line) {
			$data = "\033[1G".$data; # back to beginning of line
		} else {
			$data = "\033[".($line+1).";0H".$data; # jump
		}
		$cursor_line=$line;
		print(FIFO $data) or fifo_stop();
	}
}

# recalc the text of the nicklist item
sub calc_text {
	my ($nick) = @_;

    # handle truncation of long nicks.
	my $tmp = $nicklist_width - 3;

	my $away_prefix = $nick->{'away'}?"\033[37m":'';
	my $away_suffix = $nick->{'away'}?"\033[39m":'';
	my $text = $nick->{nick};
    $text =~ s/^(.{$tmp})..+$/$1\033[34m~\033[m/;

    my $mode = $nick->{mode};

	$nick->{text} = $sigil_cache->{$mode->{name}} . $away_prefix . $text . $away_suffix .
      (' ' x ($nicklist_width - length($nick->{nick}) - 1));

	$nick->{cmp} = $mode->{priority} . lc($nick->{nick});
}

# redraw the given nick (nr) if it is visible
sub redraw_nick_nr {
	my ($nr) = @_;
	my $line = $nr - $scroll_pos;
	if ($line >= 0 && $line < $height) {
		nicklist_write_line($line, $nicklist[$nr]->{text});
	}
}

# nick was inserted, redraw area if necessary
sub draw_insert_nick_nr {
	my ($nr) = @_;
	my $line = $nr - $scroll_pos;
	if ($line < 0) {            # nick is inserted above visible area
		$scroll_pos++;          # 'scroll' down :)
	} elsif ($line < $height) { # line is visible
		if ($mode == MODE_SCREEN) {
			need_redraw();
		} elsif ($mode == MODE_FIFO) {
            # reset color & insert line & write nick
			my $data = "\033[m\033[L". $nicklist[$nr]->{text};
			if ($line == $cursor_line) {
				$data = "\033[1G".$data; # back to beginning of line
			} else {
				$data = "\033[".($line+1).";1H".$data; # jump
			}
			$cursor_line=$line;
			print(FIFO $data) or fifo_stop();
			if ($prev_lines < $height) {
				$prev_lines++;  # the nicklist has one line more
			}
		}
	}
}

sub draw_remove_nick_nr {
	my ($nr) = @_;
	my $line = $nr - $scroll_pos;
	if ($line < 0) {            # nick removed above visible area
		$scroll_pos--;          # 'scroll' up :)
	} elsif ($line < $height) { # line is visible
		if ($mode == MODE_SCREEN) {
			need_redraw();
		} elsif ($mode == MODE_FIFO) {
			#my $data = "\033[m\033[L[i$line]". $nicklist[$nr]->{text}; # reset color & insert line & write nick
			my $data = "\033[M"; # delete line
			if ($line != $cursor_line) {
				$data = "\033[".($line+1)."d".$data; # jump
			}
			$cursor_line=$line;
			print(FIFO $data) or fifo_stop();
			if (@nicklist-$scroll_pos >= $height) {
				redraw_nick_nr($scroll_pos+$height-1);
			}
		}
	}
}

# redraw the whole nicklist
sub redraw {
	$need_redraw = 0;
	#make_nicklist();
	nicklist_write_start();
	my $line = 0;
	### draw nicklist ###
	for (my $i=$scroll_pos;$line < $height && $i < @nicklist; $i++) {
		nicklist_write_line($line++, $nicklist[$i]->{text});
	}

	### clean up other lines ###
	my $real_lines = $line;
	while ($line < $prev_lines) {
		nicklist_write_line($line++,' ' x $nicklist_width);
	}
	$prev_lines = $real_lines;
	nicklist_write_end();
}

# redraw (with little delay to avoid redrawing to much)
sub need_redraw {
	if (!$need_redraw) {
		$need_redraw = 1;
		Irssi::timeout_add_once(10, \&redraw, []);
	}
}

sub reqwholist {
	Irssi::print("Requesting who list...");
	if (!$active_channel) {
		return;
	}
	my ($channel) = @_;
	$channel = $channel->[0];
	my $channelname = $channel->{name};
	Irssi::print("Requesting who list for channel $channelname");
	$need_wholist = 0;
	$active_wholist = 1;
	$channel->{server}->send_raw("WHO $channelname");
}

sub channel_refresh {
	need_wholist($active_channel);
}

sub need_wholist {
	my ($channel) = @_;
	if(!$need_wholist) {
		$need_wholist = 1;
		Irssi::print("Scheduling who list for channel $channel->{name}");
		Irssi::timeout_add_once(10, \&reqwholist, [$channel]);
	}
}

sub sig_page_scrolled {
	$prev_lines = $height;   # we'll need to redraw everything if he scrolled up
	need_redraw;
}

# redraw (with delay) if the window is visible (only in screen mode)
sub sig_gui_print_text_finished {
	if ($need_redraw) {         # there's already a redraw 'queued'
		return;
	}
	my $window = @_[0];
	if ($window->{refnum} == Irssi::active_win->{refnum} || Irssi::settings_get_str('nicklist_screen_split_windows') eq '*') {
		need_redraw;
		return;
	}
	foreach my $win (split(/[ ,]/, Irssi::settings_get_str('nicklist_screen_split_windows'))) {
		if ($window->{refnum} == $win || $window->{name} eq $win) {
			need_redraw;
			return;
		}
	}
}

####################
##### NICKLIST #####
####################

# returns the position of the given nick(as string) in the (internal) nicklist
sub find_nick {
	my ($nick) = @_;
	for (my $i=0;$i < @nicklist; $i++) {
		if ($nicklist[$i]->{nick} eq $nick) {
			return $i;
		}
	}
	return -1;
}

# find position where nick should be inserted into the list
sub find_insert_pos {
	my ($cmp)= @_;
	for (my $i=0;$i < @nicklist; $i++) {
		if ($nicklist[$i]->{cmp} gt $cmp) {
			return $i;
		}
	}
	return scalar(@nicklist);   #last
}

# make the (internal) nicklist (@nicklist)
sub make_nicklist {
	@nicklist = ();
	$scroll_pos = 0;

	### get & check channel ###
	my $channel = Irssi::active_win->{active};

	if (!$channel || (ref($channel) ne 'Irssi::Irc::Channel' && ref($channel) ne
                      'Irssi::Silc::Channel') || $channel->{type} ne 'CHANNEL' ||
        ($channel->{chat_type} ne 'SILC' && !$channel->{names_got}) ) {

		$active_channel = undef;
		# no nicklist
	} else {
		$active_channel = $channel;

		### make nicklist ###
        my @nicks = $channel->nicks();

        my @mode_decorated_nicks =
          map { [ _select_prefix_umode($_), $_ ] } @nicks;

        my @sorted_nicks = map { $_->[1] }
          sort sort_prefixed_nicks @mode_decorated_nicks;

        # TODO: find a way to reuse these prefix lookups.
        #_debug(Dumper(\@sorted_nicks));

        foreach my $nick (@sorted_nicks) {

			my $this_nick = {
                             nick => $nick->{nick},
                             mode => _select_prefix_umode($nick),
                             away => $nick->{gone},
                            };

            calc_text($this_nick);
			push @nicklist, $this_nick;
		}
	}
	need_redraw();
}

sub sort_prefixed_nicks {
    ($a->[0]->{priority} . lc $a->[1]->{nick})
      cmp
    ($b->[0]->{priority} . lc $b->[1]->{nick});
}

# insert nick(as hash) into nicklist
# pre: cmp has to be calculated
sub insert_nick {
	my ($nick) = @_;
	my $nr = find_insert_pos($nick->{cmp});
	splice @nicklist, $nr, 0, $nick;
	draw_insert_nick_nr($nr);
}

# remove nick(as nr) from nicklist
sub remove_nick {
	my ($nr) = @_;
	splice @nicklist, $nr, 1;
	draw_remove_nick_nr($nr);
}

###################
##### ACTIONS #####
###################

# scroll the nicklist, arg = number of lines to scroll, positive = down, negative = up
sub cmd_scroll {
	if (!$active_channel) {     # not a channel active
		return;
	}
	my @nicks=Irssi::active_win->{active}->nicks;
	my $nick_count = scalar(@nicks)+0;
	my $channel = Irssi::active_win->{active};
	if (!$channel || $channel->{type} ne 'CHANNEL' || !$channel->{names_got} || $nick_count <= Irssi::settings_get_int('nicklist_height')) {
		return;
	}
	$scroll_pos += @_[0];

	if ($scroll_pos > $nick_count - $height) {
		$scroll_pos = $nick_count - $height;
	}
	if ($scroll_pos <= 0) {
		$scroll_pos = 0;
	}
	need_redraw();
}

sub is_active_channel {
	my ($server,$channel) = @_; # (channel as string)
	return ($server && $server->{tag} eq $active_channel->{server}->{tag} && $server->channel_find($channel) && $active_channel && $server->channel_find($channel)->{name} eq $active_channel->{name});
}

sub sig_who_end {
        my ($server, $channel) = @_;
        $channel =~ s/[^#]*(#\S*).*/$1/;
	if (Irssi::active_win->{active} && Irssi::active_win->{active}->{name} eq $channel) {
		make_nicklist();
	}
	Irssi::signal_stop() if $active_wholist;
	$active_wholist = 0;
}

sub sig_who_reply {
	Irssi::signal_stop() if $active_wholist;
}

sub sig_channel_wholist { # this is actualy a little late, when the names are received would be better
	my ($channel) = @_;
	if (Irssi::active_win->{active} && Irssi::active_win->{active}->{name} eq $channel->{name}) { # the channel joined is active
		make_nicklist
                                                                                                      }
}

sub sig_join {
	my ($server,$channel,$nick,$address) = @_;
	if (!is_active_channel($server,$channel)) {
		return;
	}
	my $newnick = {
                   nick => $nick,
                   mode => $server_prefix_mapping->{''},
                   away => 0,
                  };
	calc_text($newnick);
	insert_nick($newnick);
	need_wholist($active_channel);
}

sub sig_kick {
	my ($server, $channel, $nick, $kicker, $address, $reason) = @_;
	if (!is_active_channel($server,$channel)) {
		return;
	}
	my $nr = find_nick($nick);
	if ($nr == -1) {
		Irssi::print("nicklist warning: $nick was kicked from $channel, but not found in nicklist");
	} else {
		remove_nick($nr);
	}
}

sub sig_part {
	my ($server,$channel,$nick,$address, $reason) = @_;
	if (!is_active_channel($server,$channel)) {
		return;
	}
	my $nr = find_nick($nick);
	if ($nr == -1) {
		Irssi::print("nicklist warning: $nick has parted $channel, but was not found in nicklist");
	} else {
		remove_nick($nr);
	}

}

sub sig_quit {
	my ($server,$nick,$address, $reason) = @_;
	if ($server->{tag} ne $active_channel->{server}->{tag}) {
		return;
	}
	my $nr = find_nick($nick);
	if ($nr != -1) {
		remove_nick($nr);
	}
}

sub sig_nick {
	my ($server, $newnick, $oldnick, $address) = @_;
	if ($server->{tag} ne $active_channel->{server}->{tag}) {
		return;
	}
	my $nr = find_nick($oldnick);
	if ($nr != -1) {      # if nick was found (nickchange is in current channel)
		my $nick = $nicklist[$nr];
		remove_nick($nr);

		$nick->{nick} = $newnick;

		calc_text($nick);
		insert_nick($nick);
		need_wholist($active_channel);
	}
}

sub sig_mode {
	my ($channel, $nick, $setby, $mode, $type) = @_; # (nick and channel as rec)
	if ($channel->{server}->{tag} ne $active_channel->{server}->{tag} || $channel->{name} ne $active_channel->{name}) {
		return;
	}
	my $nr = find_nick($nick->{nick});
	if ($nr == -1) {
		Irssi::print("nicklist warning: $nick->{nick} had mode set on " .
                     "$channel->{name}, but was not found in nicklist");
	} else {
		my $nicklist_item = $nicklist[$nr];
		remove_nick($nr);

        $nicklist_item->{mode} = _select_prefix_umode($nick);

#		$nicklist_item->{mode} = ($nick->{op}?$MODE_OP:$nick->{halfop}?$MODE_HALFOP:$nick->{voice}?$MODE_VOICE:$MODE_NORMAL);

		calc_text($nicklist_item);
		insert_nick($nicklist_item);
	}
}

##### command binds #####
Irssi::command_bind 'nicklist' => sub {
    my ( $data, $server, $item ) = @_;
    $data =~ s/\s+$//g;
    Irssi::command_runsub ('nicklist', $data, $server, $item ) ;
};
Irssi::signal_add_first 'default command nicklist' => sub {
	# gets triggered if called with unknown subcommand
	cmd_help();
};
Irssi::command_bind('nicklist update',\&update);
Irssi::command_bind('nicklist help',\&cmd_help);
Irssi::command_bind('nicklist scroll',\&cmd_scroll);
Irssi::command_bind('nicklist fifo',\&cmd_fifo_start);
Irssi::command_bind('nicklist screen',\&cmd_screen_start);
Irssi::command_bind('nicklist screensize',\&screen_size);
Irssi::command_bind('nicklist off',\&cmd_off);

##### signals #####
Irssi::signal_add_last('window item changed', \&make_nicklist);
Irssi::signal_add_last('window changed', \&make_nicklist);
Irssi::signal_add_last('channel wholist', \&sig_channel_wholist);
Irssi::signal_add('event 315', \&sig_who_end);
Irssi::signal_add('event 352', \&sig_who_reply);
Irssi::signal_add_first('message join', \&sig_join); # first, to be before ignores
Irssi::signal_add_first('message part', \&sig_part);
Irssi::signal_add_first('message kick', \&sig_kick);
Irssi::signal_add_first('message quit', \&sig_quit);
Irssi::signal_add_first('message nick', \&sig_nick);
Irssi::signal_add_first('message own_nick', \&sig_nick);
Irssi::signal_add_first('nick mode changed', \&sig_mode);

Irssi::signal_add('setup changed', \&read_settings);

##### settings #####
Irssi::settings_add_str('nicklist', 'nicklist_screen_prefix',      '\e[m ');
Irssi::settings_add_str('nicklist', 'nicklist_screen_mode_suffix', '\e[39m');

Irssi::settings_add_str('nicklist', 'nicklist_prefix_mode_owner',  '\e[31m~\e[39m');
Irssi::settings_add_str('nicklist', 'nicklist_prefix_mode_admin',  '\e[33m&\e[39m');
Irssi::settings_add_str('nicklist', 'nicklist_prefix_mode_op',     '\e[32m@\e[39m');
Irssi::settings_add_str('nicklist', 'nicklist_prefix_mode_halfop', '\e[34m%\e[39m');
Irssi::settings_add_str('nicklist', 'nicklist_prefix_mode_voice',  '\e[36m+\e[39m');
Irssi::settings_add_str('nicklist', 'nicklist_prefix_mode_normal', ' ');


Irssi::settings_add_int('nicklist', 'nicklist_width',11);
Irssi::settings_add_int('nicklist', 'nicklist_height',24);

Irssi::settings_add_str('nicklist', 'nicklist_fifo_path',
                        Irssi::get_irssi_dir . '/nicklistfifo');

Irssi::settings_add_str('nicklist', 'nicklist_screen_split_windows', '');
Irssi::settings_add_str('nicklist', 'nicklist_automode', '');

Irssi::settings_add_bool('nicklist', 'nicklist_debug', 0);

read_settings();

if (uc(Irssi::settings_get_str('nicklist_automode')) eq 'SCREEN') {
	cmd_screen_start();
} elsif (uc(Irssi::settings_get_str('nicklist_automode')) eq 'FIFO') {
	cmd_fifo_start();
}

