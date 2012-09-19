#*******************************************************************************************************************
#* Config files                                                                                                    *
#*******************************************************************************************************************
#* File:             20-osxonly.sh                                                                                 *
#* Copyright:        (c) 2011-2012 alimonda.com; Emanuele Alimonda                                                 *
#*                   Public Domain                                                                                 *
#*******************************************************************************************************************

# Probe for Mac OS X
if [ "$(uname)" == "Darwin" ]; then
	#export TERM='xterm-256color'
	# Use a nice-looking $PS1
	export PS1='\[\033[01;32m\]\u@\h\[\033[01;34m\] \w \$\[\033[00m\] '
	export CLICOLOR=1
	# Append homebrew to the $PATH
	export PATH=$PATH:/usr/local/bin:/usr/local/sbin
fi

