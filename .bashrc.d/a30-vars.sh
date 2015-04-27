#*******************************************************************************************************************
#* Config files                                                                                                    *
#*******************************************************************************************************************
#* File:             30-vars.sh                                                                                    *
#* Copyright:        (c) 2011-2012 alimonda.com; Emanuele Alimonda                                                 *
#*                   Public Domain                                                                                 *
#*******************************************************************************************************************

# US English and UTF-8, in case it's set wrong at the OS level
export LANG='en_US.UTF-8'
# And a good editor
export EDITOR=vim
# Prepend ~/bin to $PATH
export PATH="$HOME/bin:$PATH"
# Make various commands a bit more colorful
export LESS="-RM"
#R:Raw color codes in output (don't remove color codes);
#M:Long prompts ("Line X of Y")

## OS X Only
if [ "$(uname)" == "Darwin" ]; then
	# Append homebrew to the $PATH
	export PATH=$PATH:/usr/local/bin:/usr/local/sbin
	export PYTHONPATH="$(brew --prefix)/lib/python2.7/site-packages$( [ -n "$PYTHONPATH" ] && echo ":$PYTHONPATH" )"
	export HOMEBREW_TEMP=/usr/local/temp
	export PGDATA=/usr/local/var/postgres
fi

if type rbenv &>/dev/null; then
	[ -d "/usr/local/var/rbenv" ] && export RBENV_ROOT="/usr/local/var/rbenv"
	eval "$(rbenv init -)"
fi

# vim: ts=4 sw=4
