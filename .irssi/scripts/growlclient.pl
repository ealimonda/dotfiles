#!/usr/bin/env perl -w
#
# This is a simple irssi script to send out Growl notifications ovet the network using
# Net::Growl. Currently, it sends notifications when your name is
# highlighted, and when you receive private messages.
# Based on the original growl script by Nelson Elhage and Toby Peterson.

use strict;
use vars qw($VERSION %IRSSI $growl $waiting $mutex);

use Irssi;
use Growl::GNTP;
use IO::Socket::PortState qw(check_ports);

$VERSION = '0.4';
%IRSSI = (
	authors	    => 'Emanuele Alimonda, '.
			' (based on the growl-net.pl scripts by Alex Mason, Jason Adams, Nelson Elhage, Toby Peterson, Paul Taylor)',
	contact	    => 'emanuele@alimonda.com',
	name        => 'growlclient',
	description => 'Sends out Growl notifications over the netwotk or internet for Irssi (Growl 1.3 or GFW)',
	license     => 'GPL',
	url         => 'http://growl.info/',
);

# Notification Settings
Irssi::settings_add_bool($IRSSI{'name'}, 'growl_show_privmsg', 1);
Irssi::settings_add_bool($IRSSI{'name'}, 'growl_show_hilight', 1);
Irssi::settings_add_bool($IRSSI{'name'}, 'growl_show_notify', 1);
Irssi::settings_add_bool($IRSSI{'name'}, 'growl_show_topic', 1);
Irssi::settings_add_bool($IRSSI{'name'}, 'growl_show_invite', 1);
Irssi::settings_add_bool($IRSSI{'name'}, 'growl_auto_register', 0);
# Network Settings
Irssi::settings_add_str($IRSSI{'name'}, 'growl_net_pass', 'pass');
Irssi::settings_add_str($IRSSI{'name'}, 'growl_net_client', '10.0.0.2');
Irssi::settings_add_str($IRSSI{'name'}, 'growl_net_port', '23053');
Irssi::settings_add_str($IRSSI{'name'}, 'growl_net_server', 'servername');
Irssi::settings_add_str($IRSSI{'name'}, 'growl_net_icon', 'http://10.0.0.2/irssi.png');
# Sticky Settings
Irssi::settings_add_bool($IRSSI{'name'}, 'growl_net_sticky', 0);
Irssi::settings_add_bool($IRSSI{'name'}, 'growl_net_sticky_away', 0);
# Timeout Settings
Irssi::settings_add_int($IRSSI{'name'}, 'growl_net_timeout', 1000);

my @notifies_queue = ();

sub cmd_help {
	Irssi::print('Growl-net can be configured with these settings:');

	Irssi::print('%WNotification Settings%n');
	Irssi::print('  %ygrowl_show_privmsg%n :    Notify about private messages.');
	Irssi::print('  %ygrowl_show_hilight%n :    Notify when your name is hilighted.');
	Irssi::print('  %ygrowl_show_topic%n :      Notify about topic changes.');
	Irssi::print('  %ygrowl_show_invite%n :     Notify when someone invites you to a channel.');
	Irssi::print('  %ygrowl_show_notify%n :     Notify when someone on your away list joins or leaves.');

	Irssi::print('%WNetwork Settings%n');
	Irssi::print('  %ygrowl_net_client%n :      Set to the hostname you want to recieve notifications on.');
	Irssi::print('    %R>>>> (computer.local for a Mac network. Your \'localhost\').'); 
	Irssi::print('  %ygrowl_net_port%n :        Set to the port you want to recieve notifications on.');
	Irssi::print('  %ygrowl_net_server%n :      Set to the name you want to give the machine irssi is running on. (remote)');
	Irssi::print('  %ygrowl_net_pass%n :        Set to your destination\'s Growl password. (Your machine)');
	Irssi::print('  %ygrowl_auto_register%n :   Automatically send gntp registration on script load');

	Irssi::print('%WSticky Settings%n');
	Irssi::print('  %ygrowl_net_sticky%n :      Whether growls are sticky or not (ON/OFF/TOGGLE)');
	Irssi::print('  %ygrowl_net_sticky_away%n : Sets growls to sticky when away (ON/OFF/TOGGLE)');

	Irssi::print('%WTimeout Settings%n');
	Irssi::print('  %ygrowl_net_timeout%n :     Timeout (milliseconds) to wait before sending out stacked notifications');
}

sub cmd_growl_net_test {
	my $GrowlHost	= Irssi::settings_get_str('growl_net_client');
	my $AppName	= "irssi ".Irssi::settings_get_str('growl_net_server');
	my $GrowlIcon	= Irssi::settings_get_str('growl_net_icon');
	my $GrowlServ	= Irssi::settings_get_str('growl_net_server');

	my $Sticky = set_sticky();
	
	growl_notify(
		'notification'	=> 'Private Message',
		'title'		=> 'Test:',
		'message'	=> "This is a test.\n AppName = $AppName \n GrowlHost = $GrowlHost \n GrowlServ = $GrowlServ \n Sticky = $Sticky",
		'sticky'	=> "$Sticky",
#		'priority'      => 0,
	);
} 

sub setup {
	my $GrowlHost	= Irssi::settings_get_str('growl_net_client');
	my $GrowlPort	= Irssi::settings_get_str('growl_net_port');
	my $GrowlPass	= Irssi::settings_get_str('growl_net_pass');
	my $AppName	= "Irssi ". Irssi::settings_get_str('growl_net_server');
	my $GrowlIcon	= Irssi::settings_get_str('growl_net_icon');

	Irssi::print("%G>>%n Registering to send messages to $GrowlHost:$GrowlPort");
	$growl = Growl::GNTP->new(
		AppName => $AppName,
		PeerHost => $GrowlHost,
		PeerPort => $GrowlPort,
		Password => $GrowlPass,
		AppIcon => $GrowlIcon,
	);
}

sub cmd_register {
	$growl->register([
		{ Name => "Private Message" },
		{ Name => "Hilight" },
		{ Name => "Join" },
		{ Name => "Part" },
		{ Name => "Topic" },
		{ Name => "Invite" },
	]);
}

sub check_connection {
	my $GrowlHost	= Irssi::settings_get_str('growl_net_client');
	my $GrowlPort	= Irssi::settings_get_str('growl_net_port');
	my %check = (
		tcp  => {
			$GrowlPort => {
				name => 'Growl',
			},
		},
	);

	check_ports($GrowlHost, 5, \%check);
	return $check{tcp}{$GrowlPort}{open};
}

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
		if (!check_connection()) {
			Irssi::print("The Growl server is not responding.");
			last;
		}
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

sub growl_notify {
	my $timeout = Irssi::settings_get_int('growl_net_timeout');
	$timeout = 1000 if $timeout <= 0;
	if (!check_connection()) {
		Irssi::print("The Growl server is not responding.");
		return;
	}
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
		return if($notification_name eq 'Join' || $notification_name eq 'Part' || $notification_name eq 'Topic' || $notification_name eq 'Invite');
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
	
	my $Sticky = set_sticky();
	
	growl_notify(
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
	
	my $Sticky = set_sticky();
	
	growl_notify(
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
	
	my $Sticky = set_sticky();
	
	growl_notify(
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
	
	my $Sticky = set_sticky();
	
	growl_notify(
		'notification'	=> "Part",
		'title'		=> "$realname" || "$nick",
		'message'	=> "<$nick!$user\@$host>\nHas left $server->{chatnet}",
		'priority'	=> 0,
		'sticky'	=> "$Sticky",
	);
}

sub sig_message_topic {
	return unless Irssi::settings_get_bool('growl_show_topic');
	my ($server, $channel, $topic, $nick, $address) = @_;
	
	my $Sticky = set_sticky();
	
	growl_notify(
		'notification'	=> "Topic",
		'title'		=> "$channel",
		'message'	=> "Topic: $topic",
		'priority'	=> 0,
		'sticky'	=> "$Sticky",
	);
}
sub sig_message_invite {
	return unless Irssi::settings_get_bool('growl_show_invite');
	my ($server, $channel, $nick, $address) = @_;
	
	my $Sticky = set_sticky();
	
	growl_notify(
		'notification'	=> "Invite",
		'title'		=> "$channel",
		'message'	=> "Invited by $nick",
		'priority'	=> 0,
		'sticky'	=> "$Sticky",
	);
}

sub set_sticky {
	my ($server);
	$server = Irssi::active_server();
	
	if (Irssi::settings_get_bool('growl_net_sticky_away')) {
		return $server->{usermode_away} ? 1 : 0;
		# $Sticky = Server{'usermode_away'};
	}
	return Irssi::settings_get_bool('growl_net_sticky');
}

Irssi::command_bind('growlclient',    'cmd_help');
Irssi::command_bind('gn-test',        'cmd_growl_net_test');
Irssi::command_bind('growl-register', 'cmd_register');

Irssi::signal_add_last('message private',   \&sig_message_private);
Irssi::signal_add_last('print text',        \&sig_print_text);
Irssi::signal_add_last('notifylist joined', \&sig_notify_joined);
Irssi::signal_add_last('notifylist left',   \&sig_notify_left);
Irssi::signal_add_last('message topic',     \&sig_message_topic);
Irssi::signal_add_last('message invite',    \&sig_message_invite);

$mutex = 0;
$waiting = 0;

setup();
if (Irssi::settings_get_bool('growl_auto_register')) {
	cmd_register();
}
Irssi::print('%G>>%n '.$IRSSI{name}.' '.$VERSION.' loaded (/growlclient for help. /gn-test to test.)');
