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
# Append ~/bin to $PATH
export PATH="$PATH:$HOME/bin"
# Make various commands a bit more colorful
export GREP_OPTIONS='--color=auto'
export LESS="-RM"
#R:Raw color codes in output (don't remove color codes);
#M:Long prompts ("Line X of Y")

## OS X Only
if [ "$(uname)" == "Darwin" ]; then
	# Append homebrew to the $PATH
	export PATH=$PATH:/usr/local/bin:/usr/local/sbin
fi

# vim: ts=4 sw=4
