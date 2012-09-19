#!/usr/bin/env perl -w
#
# This is a simple irssi script to send out Growl notifications ovet the network using
# Net::Growl. Currently, it sends notifications when your name is
# highlighted, and when you receive private messages.
# Based on the original growl script by Nelson Elhage and Toby Peterson.

use strict;
use vars qw($VERSION %IRSSI $AppName $GrowlHost $GrowlPass $GrowlServ $Sticky $testing $growl $GrowlIcon $waiting);

use Irssi;
use Growl::GNTP;

$VERSION = '0.03b1';
%IRSSI = (
	authors	    => 'Syao (based on growl-net.pl script by Alex Mason, Jason Adams, Nelson Elhage, Toby Peterson)',
	contact	    => 'syao@dotalux.com, syao @ irc.rizon.net; (axman6@gmail.com, Hanji@users.sourceforge.net, toby@opendarwin.org)',
	name        => 'growlclient',
	description => 'Sends out Growl notifications over the netwotk or internet for Irssi (Growl 1.3 or GFW)',
	license     => 'GPL',
	url         => 'http://axman6.homeip.net/blog/growl-net-irssi-script/ , http://growl.info/',
);

sub cmd_growl_net {
	Irssi::print('%G>>%n Growl-net can be configured with these settings:');
	Irssi::print('%G>>%n growl_show_privmsg : Notify about private messages.');
	Irssi::print('%G>>%n growl_show_hilight : Notify when your name is hilighted.');
	Irssi::print('%G>>%n growl_show_notify : Notify when someone on your away list joins or leaves.');
	Irssi::print('%G>>%n growl_net_client : Set to the hostname you want to recieve notifications on.');
	Irssi::print('%R>>>>>>%n (computer.local for a Mac network. Your \'localhost\').'); 
	Irssi::print('%G>>%n growl_net_server : Set to the name you want to give the machine irssi is running on. (remote)');
	Irssi::print('%G>>%n growl_net_pass : Set to your destination\'s Growl password. (Your machine)');
	Irssi::print('%G>>%n growl_net_sticky : Whether growls are sticky or not (ON/OFF/TOGGLE)');
	Irssi::print('%G>>%n growl_net_sticky_away : Sets growls to sticky when away (ON/OFF/TOGGLE)');
}

sub cmd_growl_net_test {
	set_sticky();
	
	notify(
		'notification'	=> 'Private Message',
		'title'		=> 'Test:',
		'message'	=> "This is a test.\n AppName = $AppName \n GrowlHost = $GrowlHost \n GrowlServ = $GrowlServ \n Sticky = $Sticky\n Away = $testing",
		'sticky'	=> "$Sticky",
#		'priority'      => 0,
	);
} 

Irssi::settings_add_bool($IRSSI{'name'}, 'growl_show_privmsg', 1);
Irssi::settings_add_bool($IRSSI{'name'}, 'growl_show_hilight', 1);
Irssi::settings_add_bool($IRSSI{'name'}, 'growl_show_notify', 1);
Irssi::settings_add_str($IRSSI{'name'}, 'growl_net_pass', 'pass');
Irssi::settings_add_str($IRSSI{'name'}, 'growl_net_client', '10.0.0.2');
Irssi::settings_add_str($IRSSI{'name'}, 'growl_net_server', 'servername');
Irssi::settings_add_str($IRSSI{'name'}, 'growl_net_icon', '');
Irssi::settings_add_bool($IRSSI{'name'}, 'growl_net_sticky', 0);
Irssi::settings_add_bool($IRSSI{'name'}, 'growl_net_sticky_away', 0);
Irssi::settings_add_int($IRSSI{'name'}, 'growl_net_timeout', 1000);

$GrowlHost 	= Irssi::settings_get_str('growl_net_client');
$GrowlPass 	= Irssi::settings_get_str('growl_net_pass');
$GrowlServ 	= Irssi::settings_get_str('growl_net_server');
$GrowlIcon 	= Irssi::settings_get_str('growl_net_icon');

$AppName	= "irssi $GrowlServ";

my $mutex = 0;
my @notifies_queue = ();
my $timeout = Irssi::settings_get_int('growl_net_timeout');
$timeout = 1000 if $timeout <= 0;

$waiting = 0;

$growl = Growl::GNTP->new(
	AppName  => $AppName,
	PeerHost => $GrowlHost,
	Password => $GrowlPass,
	AppIcon  => $GrowlIcon,
);

$growl->register([
	{ Name => "Private Message" },
	{ Name => "Hilight" },
	{ Name => "Join" },
	{ Name => "Part" },
]);

sub lock {
	return; # FIXME
#	Irssi::print('Requesting lock');
	while( $mutex ) {
	}
	$mutex = 1;
#	Irssi::print('Mutex locked');
}

sub unlock {
	$mutex = 0;
#	Irssi::print('Mutex unlocked');
}

sub timeout_clear {
	lock();
#	Irssi::print('Waiting: '.$waiting);
	$waiting = 0;

	my %messages = (
		'Private Message' => '',
		'Hilight' => '',
	);
	my %count = (
		'Private Message' => 0,
		'Hilight' => 0,
	);
#	Irssi::print('Queue length: '.$#notifies_queue);
	while($#notifies_queue > 0) {
#		Irssi::print('Notifies queue length: '.$#notifies_queue);
		my %message = %{ shift(@notifies_queue) };
		next if $message{'message'} =~ /^(->)?(\d{2}:){2}\d{2}>/ ;
#		Irssi::print('Notification: ' . $message{'notification'});
		$messages{$message{'notification'}} .= "\n" . "====================\n" . $message{'title'} . ": " . $message{'message'};
		$count{$message{'notification'}}++;
		if($count{$message{'notification'}} >= 8) {
			$growl->notify(
				Event    => $message{'notification'},
				Title    => $message{'notification'},
				Message  => $messages{$message{'notification'}},
				Priority => 0,
				Sticky   => 1
			);
			$messages{$message{'notification'}} = "";
			$count{$message{'notification'}} = 0;
		}
	}
#	Irssi::print('Private messages: '.$count{'Private Message'});
#	Irssi::print('Hilights: '.$count{'Hilight'});
	foreach my $key (keys %messages) {
		$growl->notify(
			Event    => $key,
			Title    => $key,
			Message  => $messages{$key},
			Priority => 0,
			Sticky   => 1,
		) if($count{$key} > 0);
	}
	unlock();
}

sub notify {
	my %notify_args = @_;
	my ($notification_name, $title, $message, $sticky);
	$notification_name = $notify_args{'notification'};
	$title = $notify_args{'title'};
	$message = $notify_args{'message'} || '0';
	$sticky = $notify_args{'sticky'};
		
#	Irssi::print('notifying');
	lock();
#	Irssi::print('Waiting: '.$waiting);
	if( $#notifies_queue > 0 || $waiting != 0) {
#		Irssi::print('entering queue');
		return if($notification_name eq 'Join' || $notification_name eq 'Part');
		push @notifies_queue, { 'notification' => $notification_name, 'title' => $title, 'message' => $message, 'sticky' => $sticky };
#		Irssi::print('Waiting: '.$waiting);
		$waiting = Irssi::timeout_add_once($timeout, 'timeout_clear', undef) unless($waiting);
	} else {
#		Irssi::print('skipping queue');
		Irssi::remove_timeout($waiting) if ($waiting);
		$waiting = Irssi::timeout_add_once($timeout, 'timeout_clear', undef);
		
		$growl->notify(
			Event    => $notification_name,
			Title    => $title,
			Message  => $message,
			Priority => 0,
			Sticky   => $sticky,
		);
	}
#	Irssi::print('Waiting: '.$waiting);
	unlock();
}

sub sig_message_private ($$$$) {
	return unless Irssi::settings_get_bool('growl_show_privmsg');

	my ($server, $data, $nick, $address) = @_;
	
	set_sticky();
	
	notify(
		'notification'	=> "Private Message",
		'title'		=> "$nick",
		'message'	=> "$data",
		'priority'	=> 0,
		'sticky'	=> "$Sticky",
	);
}

sub sig_print_text ($$$) {
	return unless Irssi::settings_get_bool('growl_show_hilight');

	my ($dest, $text, $stripped) = @_;
	
	set_sticky();
	
	notify(
		'notification'	=> "Hilight",
		'title'		=> "$dest->{target}",
		'message'	=> "$stripped",
		'priority'	=> 0,
		'sticky'	=> "$Sticky",
	) if ($dest->{level} & MSGLEVEL_HILIGHT);
}

sub sig_notify_joined ($$$$$$) {
	return unless Irssi::settings_get_bool('growl_show_notify');
	
	my ($server, $nick, $user, $host, $realname, $away) = @_;
	
	set_sticky();
	
	notify(
		'notification'	=> "Join",
		'title'		=> "$realname" || "$nick",
		'message'	=> "<$nick!$user\@$host>\nHas joined $server->{chatnet}",
		'priority'	=> 0,
		'sticky'	=> "$Sticky",
	);
}

sub sig_notify_left ($$$$$$) {
	return unless Irssi::settings_get_bool('growl_show_notify');
	
	my ($server, $nick, $user, $host, $realname, $away) = @_;
	
	set_sticky();
	
	notify(
		'notification'	=> "Part",
		'title'		=> "$realname" || "$nick",
		'message'	=> "<$nick!$user\@$host>\nHas left $server->{chatnet}",
		'priority'	=> 0,
		'sticky'	=> "$Sticky",
	);
}

sub set_sticky {
	my ($server);
	$server = Irssi::active_server();
	
	if (Irssi::settings_get_bool('growl_net_sticky_away')) {
		$Sticky = $server->{usermode_away} ? 1 : 0;
		# $Sticky = Server{'usermode_away'};
	} else {
		$Sticky = Irssi::settings_get_bool('growl_net_sticky');
	}
}

Irssi::command_bind('growlclient', 'cmd_growl_net');
Irssi::command_bind('gn-test', 'cmd_growl_net_test');

Irssi::signal_add_last('message private', \&sig_message_private);
Irssi::signal_add_last('print text', \&sig_print_text);
Irssi::signal_add_last('notifylist joined', \&sig_notify_joined);
Irssi::signal_add_last('notifylist left', \&sig_notify_left);

Irssi::print('%G>>%n '.$IRSSI{name}.' '.$VERSION.' loaded (/growlclient for help. /gn-test to test.)');
