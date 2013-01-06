#!/usr/bin/env bash
if [ "$BASH_IT_SAFE_CHARSET" == "true" ]; then
  SCM_CLEAN_CHAR="."
  SCM_DIRTY_CHAR="!"
  SCM_NONE_CHAR="${bold_yellow}=${normal}"
  SCM_GIT_CHAR="${bold_cyan}g${normal}"
  SCM_SVN_CHAR="${bold_cyan}s${normal}"
  SCM_HG_CHAR="${bold_red}m${normal}"
  STATUSOK_CHAR="${green}*${normal}"
  STATUSERR_CHAR="${red}@${normal}"
else
  SCM_CLEAN_CHAR="✓"
  SCM_DIRTY_CHAR="✗"
  SCM_NONE_CHAR="${bold_yellow}○${normal}"
  SCM_GIT_CHAR="${bold_cyan}±${normal}"
  SCM_SVN_CHAR="${bold_cyan}⑆${normal}"
  SCM_HG_CHAR="${bold_red}☿${normal}"
  STATUSOK_CHAR="${green}•${normal}"
  STATUSERR_CHAR="${red}▪${normal}"
fi
SCM_THEME_PROMPT_CLEAN=" ${green}${SCM_CLEAN_CHAR}${normal}"
SCM_THEME_PROMPT_DIRTY=" ${bold_red}${SCM_DIRTY_CHAR}${normal}"
SCM_THEME_PROMPT_PREFIX=""
SCM_THEME_PROMPT_SUFFIX=""
case "$(id -u)" in
  0)
    my_user_color="${light_red}"
    ;;
  *)
    my_user_color="${green}"
    ;;
esac

export MYSQL_PS1="(\u@\h) [\d]> "

emi_scm_prompt() {
  scm_prompt_char
  if [ "$SCM_CHAR" == "$SCM_NONE_CHAR" ]; then
    echo "$SCM_CHAR|"
    return
  elif [ $SCM_CHAR = $SCM_GIT_CHAR ]; then
    echo "$SCM_CHAR:$(git_prompt_status)|"
  else
    echo "$SCM_CHAR:$(scm_prompt_info)|"
  fi
}

function prompt_setter() {
# Save history
#history -a
#history -c
#history -r
if [ $? -ne 0 ]; then
  local LASTSTATUS="$STATUSERR_CHAR"
else
  local LASTSTATUS="$STATUSOK_CHAR"
fi
# Prepend some useful info to the $PS1
local PREPS1
# If we're inside ranger (and how many levels)
[ -n "$RANGER_LEVEL" ] && PREPS1="${bold_yellow}R${RANGER_LEVEL}${normal}|"
# If we're inside a vcsh (and which repository it belongs to)
[ -n "$VCSH_REPO_NAME" ] && PREPS1="${bold_yellow}(${VCSH_REPO_NAME})${normal}|"
# vim shell
[ -n "$VIMRUNTIME" ] && PREPS1="${yellow}v${normal}|"
#[ -n "$PREPS1" ] && PREPS1="$PREPS1 "

PS1="${LASTSTATUS}${normal}[${PREPS1}$(emi_scm_prompt)$(battery_charge)${normal}] ${my_user_color}\u@\h ${bold_blue}\w${normal} ${blue}\$${normal} "
}

PROMPT_COMMAND=prompt_setter

git_prompt_status() {
  local git_status_output
  git_status_output=$(git status 2> /dev/null )
  if [ -n "$(echo $git_status_output | grep 'Changes not staged')" ]; then
    git_status="${bold_red}$(scm_prompt_info) ${SCM_DIRTY_CHAR}"
  elif [ -n "$(echo $git_status_output | grep 'Changes to be committed')" ]; then
    git_status="${bold_yellow}$(scm_prompt_info) ^"
  elif [ -n "$(echo $git_status_output | grep 'Untracked files')" ]; then
    git_status="${bold_cyan}$(scm_prompt_info) +"
  elif [ -n "$(echo $git_status_output | grep 'nothing to commit')" ]; then
    git_status="${bold_green}$(scm_prompt_info) ${green}${SCM_CLEAN_CHAR}"
  else
    git_status="$(scm_prompt_info)"
  fi
  echo "$git_status${normal}"
}

function svn_prompt_info {
svn_prompt_vars
echo -e "$SCM_PREFIX$SCM_BRANCH$SCM_CHANGE$SCM_STATE$SCM_SUFFIX"
}

function svn_prompt_vars {
if [[ -n $(svn status 2> /dev/null) ]]; then
  SCM_DIRTY=1
  SCM_STATE=${SVN_THEME_PROMPT_DIRTY:-$SCM_THEME_PROMPT_DIRTY}
else
  SCM_DIRTY=0
  SCM_STATE=${SVN_THEME_PROMPT_CLEAN:-$SCM_THEME_PROMPT_CLEAN}
fi
SCM_PREFIX=${SVN_THEME_PROMPT_PREFIX:-$SCM_THEME_PROMPT_PREFIX}
SCM_SUFFIX=${SVN_THEME_PROMPT_SUFFIX:-$SCM_THEME_PROMPT_SUFFIX}
SCM_BRANCH=$(svn info 2> /dev/null | awk -F/ '/^URL:/ { for (i=0; i<=NF; i++) { if ($i == "branches" || $i == "tags" ) { print $(i+1); break }; if ($i == "trunk") { print $i; break } } }') || return
SCM_CHANGE=$(svn info 2> /dev/null | sed -ne 's#^Revision: #@#p' )
}

function git_prompt_vars { 
SCM_DIRTY=0;
SCM_STATE=''
SCM_PREFIX=${GIT_THEME_PROMPT_PREFIX:-$SCM_THEME_PROMPT_PREFIX};
SCM_SUFFIX=${GIT_THEME_PROMPT_SUFFIX:-$SCM_THEME_PROMPT_SUFFIX};
local ref=$(git symbolic-ref HEAD 2> /dev/null);
SCM_BRANCH=${ref#refs/heads/};
SCM_CHANGE=$(git rev-parse HEAD 2>/dev/null)
}

# vim: set ts=2 sw=2 et: #
