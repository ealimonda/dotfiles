#!/usr/bin/env perl
#

use strict;
use warnings;

my $didzero = 0;

while (<>) {
	chomp;
	my $line = $_;
	# num%title:dir:command
	if ($line =~ /^([0-9]+)(?:%(.+))?:(.*):(.*)$/) {
		my ($num, $title, $dir, $command) = ($1, $2, $3, $4);
		my @tmuxcmd = ("tmux", "select-window", "-t", "stuff:$num");
		$dir =~ s/^~/$ENV{'HOME'}/ if $dir;
		chdir;
		if ($num == 0 and not $didzero) {
			$didzero = 1;
			if ($dir) {
				$tmuxcmd[1] = "send-keys";
				push @tmuxcmd, "cd '$dir'";
				system(@tmuxcmd);
				pop @tmuxcmd;
			}
			if ($title) {
				$tmuxcmd[1] = "rename-window";
				push @tmuxcmd, $title;
				system(@tmuxcmd);
				pop @tmuxcmd;
			}
		} else {
			system(@tmuxcmd);
			my $create = $?;
			$tmuxcmd[1] = $create ? "new-window" : "rename-window";
			chdir $dir if $dir;
			if ($create) {
				push @tmuxcmd, ("-n", $title) if $title;
				system(@tmuxcmd);
				pop @tmuxcmd if $title;
				pop @tmuxcmd if $title;
			} else {
				if ($title) {
					push @tmuxcmd, $title;
					system(@tmuxcmd);
					pop @tmuxcmd;
				}
				$tmuxcmd[1] = "split-window";
				system(@tmuxcmd);
			}
		}
		if ($command) {
			$tmuxcmd[1] = "send-keys";
			push @tmuxcmd, "$command";
			system(@tmuxcmd);
			pop @tmuxcmd;
		}
	} else {
		print "Unrecognized line: $line\n";
	}
}
