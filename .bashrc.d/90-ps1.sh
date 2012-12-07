#*******************************************************************************************************************
#* Config files                                                                                                    *
#*******************************************************************************************************************
#* File:             90-ps1.sh                                                                                     *
#* Copyright:        (c) 2011-2012 alimonda.com; Emanuele Alimonda                                                 *
#*                   Public Domain                                                                                 *
#*******************************************************************************************************************

# Prepend some useful info to the $PS1
# If we're inside ranger (and how many levels)
#[ -n "$RANGER_LEVEL" ] && export PS1="\[\033[01;30m\][R${RANGER_LEVEL}] ${PS1}"
# If we're inside a vcsh (and which repository it belongs to)
#[ -n "$VCSH_REPO_NAME" ] && export PS1="\[\033[01;33m\](${VCSH_REPO_NAME}) ${PS1}"

# vim: ts=4 sw=4
