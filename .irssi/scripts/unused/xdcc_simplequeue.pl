# script for irssi
# Copyright (c) 2007-2008 Heikki Hokkanen <hoxu at users.sf.net>
# 
# TODO/IDEAS:
# - dcc autoget support (detect which gets to accept) (dcc get receive)

use Irssi;
use strict;

use vars qw($VERSION %IRSSI);

$VERSION = '0.0.2';
%IRSSI = (
	authors => 'Heikki Hokkanen',
	contact => 'hoxu at users.sf.net',
	name => 'xdcc-simplequeue',
	description => 'Simple (=working) XDCC queue script. Next message is sent when a DCC SEND finishes. Supports multiple networks and nicks/bots. Requires dcc_autoget to be ON',
	license => 'GPLv2',
	irc => 'chat.freenode.net / #fealdia',
);

# -----[ Variables ]------------------------------------------------------------
my %queue = (); # network -> nick -> @messages

# -----[ Functions ]------------------------------------------------------------
sub message {
	my ($msg) = @_;
	print("%Gxdccqueue%n: $msg");
}

sub debug {
	my ($msg) = @_;
	message("DEBUG: $msg") if Irssi::settings_get_bool('xdccqueue_debug');
}

##
# Check if nick has given type of DCC active in network with tag.
sub dcc_has_nick_active {
	my ($type, $tag, $nick) = @_;
	
	foreach my $dcc (Irssi::Irc::dccs()) {
		if ($dcc->{type} eq $type and $tag eq $dcc->{servertag} and $nick eq lc($dcc->{nick})) {
			return 1;
		}
	}
	return 0;
}

sub queue_add {
	my ($server, $nick, $message) = @_;

	my $tag = $server->{tag};

	#message("Queued message for $nick @ $tag");
	push(@{$queue{$tag}{lc($nick)}}, $message);
}

sub queue_addpack {
	my ($server, $nick, $pack) = @_;
	
	#debug("addpack $pack");
	
	my $format = Irssi::settings_get_str('xdccqueue_request_format');

	$format =~ s/NUM/$pack/;
	queue_add($server, $nick, $format);
}

##
# check the queue for any messages that can be sent now (to bots that don't have DCC GET active).
sub queue_check {
	foreach my $network (keys(%queue)) {
		foreach my $nick (keys(%{$queue{$network}})) {
			if (!dcc_has_nick_active('GET', $network, $nick)) {
				# get next message
				my $message = queue_pop($network, $nick, 0);

				message("Sending next request for $nick @ $network, ". queue_count($network, $nick) ." left");

				# send next message
				Irssi::server_find_tag($network)->command("msg $nick $message");

				next; # send only one per nick
			}
		}
	}
}

sub queue_count {
	my ($network, $nick) = @_;

	if (exists($queue{$network}{$nick})) {
		return scalar(@{$queue{$network}{$nick}});
	}
	return 0;
}

##
# Remove and return a message from queue. Return undef if none at index.
sub queue_pop {
	my ($network, $nick, $index) = @_;

	if ($index >= scalar(@{$queue{$network}{$nick}})) {
		return undef;
	}

	my $res = splice(@{$queue{$network}{$nick}}, $index, 1);
	if (scalar(@{$queue{$network}{$nick}}) == 0) {
		delete $queue{$network}{$nick};
	}
	if (scalar(keys(%{$queue{$network}})) == 0) {
		delete $queue{$network};
	}
	return $res;
}

##
# Handle the /xdccqueue command
sub cmd_xdccqueue {
	my ($data, $server, $witem) = @_;

	if (!$server) {
		message("Must be connected to a network!");
		return;
	}

	my @parts = split(/ +/, $data);
	my $cmd = @parts[0];
	my $tag = $server->{tag};

	if ($cmd eq 'add' and scalar(@parts) >= 3) {
		my $nick = @parts[1];
		my $message = join(' ', splice(@parts, 2));

		queue_add($server, $nick, $message);
		queue_check();
	}
	elsif ($cmd eq 'addpacks' and scalar(@parts) >= 2) {
		my $nick = @parts[1];
		foreach my $param (splice(@parts, 2)) {
			#debug("addpacks $param");

			if (index($param, '-') != -1) {
				my ($start, $end) = split('-', $param, 2);
				for (my $i = int($start); $i <= int($end); $i++) {
					queue_addpack($server, $nick, $i);
				}
			}
			else {
				queue_addpack($server, $nick, $param);
			}
		}
		queue_check()
	}
	elsif ($cmd eq 'clear' and scalar(@parts) >= 2) {
		delete $queue{$tag}{@parts[1]};
		if (scalar(keys(%{$queue{$tag}})) == 0) {
			delete $queue{$tag};
		}
		message("Cleared queue for @parts[1] @ $tag");
	}
	elsif ($cmd eq 'del' and scalar(@parts) >= 3) {
		queue_pop($tag, @parts[1], int(@parts[2]));
	}
	elsif ($cmd eq 'list') {
		message("XDCC queue list:");
		foreach my $tag (keys(%queue)) {
			message(" Network: $tag");
			foreach my $nick (keys(%{$queue{$tag}})) {
				message("  Nick: $nick : ". join(', ', @{$queue{$tag}{$nick}}));
			}
		}
	}
	else {
		#message("Unrecognized command: $data");
		message("Usage: xdccqueue <command> [parameters]");
		message("  add <name> <command>");
		message("  addpacks <name> <N..>");
		message("  clear <name> - clear queued messages of name");
		message("  del <name> <#> - 0..N");
		message("  list - list all queued messages");
		message("Examples:");
		message("  xdccqueue add xdccbot xdcc send #9378");
		message("  set xdcc_request_format xdcc send #NUM");
		message("  xdccqueue addpacks xdccbot 9375 9378-9400");
		message("Also see /set xdccqueue for settings");
	}
}

##
# If nick is one in queue, send next message if any
sub sig_dcc_closed {
	my ($dcc) = @_;

	debug("signal dcc closed");

	my $network = $dcc->{servertag};
	my $nick = lc($dcc->{nick});
	my $arg = $dcc->{arg};

	debug("network $network nick $nick arg $arg");

	# check if the nick has messages in dcc queue, if it does, send the next message
	if ($dcc->{type} eq 'GET') {
		if (exists($queue{$network}{$nick})) {
			my $message = queue_pop($network, $nick, 0);
			message("Sending next message to $nick @ $network: $message, ". queue_count($network, $nick) ." left");
			#$dcc->{server}->send_message($nick, $message, 1);
			$dcc->{server}->command("msg $nick $message");
		}
	}
}

# -----[ Commands ]-------------------------------------------------------------

Irssi::command_bind('xdccqueue', 'cmd_xdccqueue');

# -----[ Signal hooks ]---------------------------------------------------------
# dcc created
# dcc closed -> get next in queue for network/name
Irssi::signal_add('dcc destroyed', 'sig_dcc_closed');

# -----[ Settings ]-------------------------------------------------------------

Irssi::settings_add_bool($IRSSI{name}, 'xdccqueue_debug', 0);
Irssi::settings_add_str($IRSSI{name}, 'xdccqueue_request_format', 'xdcc send #NUM');

# -----[ Setup ]----------------------------------------------------------------

message("$IRSSI{name} loaded");

# I hate perl. :-(
