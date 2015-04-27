#*******************************************************************************************************************
#* Config files                                                                                                    *
#*******************************************************************************************************************
#* File:             .bash_profile                                                                                 *
#* Copyright:        (c) 2012 alimonda.com; Emanuele Alimonda                                                      *
#*                   Public Domain                                                                                 *
#*******************************************************************************************************************

# When bash is invoked as an interactive login shell, or as a non-interactive shell with the --login option, it first  reads  and  executes  commands
# from  the  file  /etc/profile,  if that file exists.  After reading that file, it looks for ~/.bash_profile, ~/.bash_login, and ~/.profile, in that
# order, and reads and executes commands from the first one that exists and is readable.  The --noprofile option  may  be  used  when  the  shell  is
# started to inhibit this behavior.
__hostname="$(hostname)"
if [ -f /etc/profile ]; then
    source /etc/profile
fi
if [[ "$__hostname" =~ ^freya[a-z.-]* ]]; then
	UNISONLOCALHOSTNAME=Freya.local
fi

# This file is sourced by bash for login shells.  The following line
# runs your .bashrc and is recommended by the bash info pages.
[[ -f ~/.bashrc ]] && . ~/.bashrc

if [[ "$__hostname" =~ quetzal[a-z.]* ]]; then
	fortune starwars bofh-excuses off/linux kernelcookies
fi

unset __hostname
