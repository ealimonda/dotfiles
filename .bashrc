#*******************************************************************************************************************
#* Config files                                                                                                    *
#*******************************************************************************************************************
#* File:             .bashrc                                                                                       *
#* Copyright:        (c) 2011-2012 alimonda.com; Emanuele Alimonda                                                 *
#*                   Public Domain                                                                                 *
#*******************************************************************************************************************

# This file is sourced by all *interactive* bash shells on startup,
# including some apparently interactive shells such as scp and rcp
# that can't tolerate any output.  So make sure this doesn't display
# anything or bad things will happen !

# Test for an interactive shell.  There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.

# Source all files starting with a in ~/.bashrc.d/
for eachFile in ${HOME}/.bashrc.d/a*.sh; do
	source "${eachFile}"
done

if [[ $- != *i* ]] ; then
	# Shell is non-interactive.  Be done now!
	return
fi

#### bash-it
# Path to the bash it configuration
export BASH_IT=$HOME/.bash_it

# Lock and Load a custom theme file
# location /.bash_it/themes/
#export BASH_IT_THEME='bobby'
export BASH_IT_THEME='emi'
if [[ ("$TERM_PROGRAM" != "iTerm.app" && "$TERM_PROGRAM" != "Apple_Terminal") || ! $TERM =~ [a-z]*-256color ]]; then
	export BASH_IT_SAFE_CHARSET="true"
else
	unset BASH_IT_SAFE_CHARSET
fi

# Your place for hosting Git repos. I use this for private repos.
#export GIT_HOSTING='git.example.com'

# Set my editor and git editor
#export EDITOR="/usr/bin/mate -w"
#export GIT_EDITOR='/usr/bin/mate -w'

# Change this to your console based IRC client of choice.
#export IRC_CLIENT='irssi'

# Set this to the command you use for todo.txt-cli
#export TODO="t"

# Load Bash It
[ -f "$BASH_IT/bash_it.sh" ] && . $BASH_IT/bash_it.sh
#### end bash-it

# Put your fun stuff here.

# Source all files starting with i in ~/.bashrc.d/
for eachFile in ${HOME}/.bashrc.d/i*.sh; do
	source "${eachFile}"
done

if [ "${BASH_VERSION%%\.*}" -ge 4 ]; then
	if type brew >/dev/null 2>&1; then
		BASHCOMPLOADER="$(brew --prefix)/share/bash-completion/bash_completion"
	else
		BASHCOMPLOADER="/etc/profile.d/bash-completion.sh"
	fi
	if [ -f "${BASHCOMPLOADER}" ]; then
		. "${BASHCOMPLOADER}"
	fi
fi
