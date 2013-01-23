#!/bin/bash

PATH="$PATH:$HOME/bin:/usr/local/bin"
[ -n "$1" -a -d "$1" ] && cd "$1";
if ! tmux has -t stuff 1>&- 2>&-; then
	tmuxattach --onlystart;
fi;
tmux new-window -t stuff
