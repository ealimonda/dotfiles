#*******************************************************************************************************************
#* Config files                                                                                                    *
#*******************************************************************************************************************
#* File:             20-osxonly.sh                                                                                 *
#* Copyright:        (c) 2011-2012 alimonda.com; Emanuele Alimonda                                                 *
#*                   Public Domain                                                                                 *
#*******************************************************************************************************************

# Probe for Mac OS X
if [ "$(uname)" == "Darwin" ]; then
	# http://blog.warrenmoore.net/blog/2010/01/09/make-terminal-follow-aliases-like-symlinks/
	function cd {
		if [ ${#1} == 0 ]; then
			builtin cd
		elif [ -d "${1}" ]; then
			builtin cd "${1}"
		elif [[ -f "${1}" || -L "${1}" ]]; then
			path=$(getTrueName "$1")
			builtin cd "$path"
		else
			builtin cd "${1}"
		fi
	}

	function intmux {
		[ -n "$1" -a -d "$1" ] && cd "$1"
		# Check for session
		if ! tmux has -t stuff >&- 2>&-; then
			# Start a new session
			tmuxattach --onlystart
		fi
		tmux new-window -t stuff && tmux rename-window -t stuff "($(basename "$PWD"))"
	}

	function dequarantine {
		while [ $# -gt 0 ]; do
			THISFILE="$1"
			shift
			[ -z "$THISFILE" -o ! -e "$THISFILE" ] && continue
			xattr -d com.apple.quarantine "$THISFILE" 2>/dev/null
		done
	}

	#export TERM='xterm-256color'
	# Use a nice-looking $PS1
	#export PS1='\[\033[01;32m\]\u@\h\[\033[01;34m\] \w \$\[\033[00m\] '
	shopt -s checkwinsize
	export CLICOLOR=1
	# Append homebrew to the $PATH
	export PATH=$PATH:/usr/local/bin:/usr/local/sbin
fi

# vim: ts=4 sw=4
