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
  SCM_GIT_BEHIND_CHAR="b:"
  SCM_GIT_AHEAD_CHAR="a:"
  RBENV_THEME_PROMPT_PREFIX="|r:"
  RBENV_THEME_PROMPT_SUFFIX=""
else
  SCM_CLEAN_CHAR="✓"
  SCM_DIRTY_CHAR="✗"
  SCM_NONE_CHAR="${bold_yellow}○${normal}"
  SCM_GIT_CHAR="${bold_cyan}±${normal}"
  SCM_SVN_CHAR="${bold_cyan}⑆${normal}"
  SCM_HG_CHAR="${bold_cyan}☿${normal}"
  STATUSOK_CHAR="${green}•${normal}"
  STATUSERR_CHAR="${red}▪${normal}"
  SCM_GIT_BEHIND_CHAR="↓"
  SCM_GIT_AHEAD_CHAR="↑"
  RBENV_THEME_PROMPT_PREFIX="|${yellow}◆"
  RBENV_THEME_PROMPT_SUFFIX="${normal}"
fi
SCM_THEME_PROMPT_CLEAN=" ${green}${SCM_CLEAN_CHAR}${normal}"
SCM_THEME_PROMPT_DIRTY=" ${bold_red}${SCM_DIRTY_CHAR}${normal}"
SCM_THEME_PROMPT_PREFIX=""
SCM_THEME_PROMPT_SUFFIX=""

export MYSQL_PS1="(\u@\h) [\d]> "

emi_scm_prompt() {
  scm_prompt_char
  if [ "$SCM_CHAR" == "$SCM_NONE_CHAR" ]; then
    echo "$SCM_CHAR"
    return
  elif [ $SCM_CHAR = $SCM_GIT_CHAR ]; then
    echo "$SCM_CHAR:$(git_prompt_status)"
  else
    echo "$SCM_CHAR:$(scm_prompt_info)"
  fi
}

function rbenv_version_prompt {
  if type rbenv &> /dev/null; then
    rbenv=$(rbenv version-name) || return
    #$(rbenv commands | grep -q gemset) && gemset=$(rbenv gemset active 2> /dev/null) && rbenv="$rbenv@${gemset%% *}"
    if [ -n "$rbenv" -a "$rbenv" != 'system' ]; then
      echo -e "$RBENV_THEME_PROMPT_PREFIX$rbenv$RBENV_THEME_PROMPT_SUFFIX"
    fi
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
  local PREPS1=''
  # If we're inside ranger (and how many levels)
  [ -n "$RANGER_LEVEL" ] && PREPS1="${bold_yellow}R${RANGER_LEVEL}${normal}|$PREPS1"
  # If we're inside a vcsh (and which repository it belongs to)
  [ -n "$VCSH_REPO_NAME" ] && PREPS1="${bold_yellow}(${VCSH_REPO_NAME})${normal}|$PREPS1"
  # vim shell
  [ -n "$VIMRUNTIME" ] && PREPS1="${yellow}v${normal}|$PREPS1"
  #[ -n "$PREPS1" ] && PREPS1="$PREPS1 "

  #PS1="${LASTSTATUS}${normal}[${PREPS1}$(emi_scm_prompt)$(battery_charge)${normal}] ${my_user_color}\u@\h ${bold_blue}\w${normal} ${blue}\$${normal} "
  case "$(id -u)" in
    0)
      my_user_color="${light_red}"
      ;;
    *)
      if sudo -n uptime 2>&1 | grep -q "load"; then
        my_user_color="${yellow}"
      else
        my_user_color="${green}"
      fi
      ;;
  esac
  PS1="${LASTSTATUS}${normal}[${PREPS1}$(emi_scm_prompt)${normal}$(rbenv_version_prompt)] ${my_user_color}\u@\h ${bold_blue}\w${normal} ${blue}\$${normal} "
}

PROMPT_COMMAND=prompt_setter

git_prompt_status() {
  SCM_GIT_AHEAD=''
  SCM_GIT_BEHIND=''
  SCM_GIT_STASH=''
  local git_status_output=$(git status -bs --porcelain 2> /dev/null )
  local git_status_branch=$(grep ^# <<< "${git_status_output}")
  local git_color=''
  local git_char=''
  git_status_output=$(grep -v ^# <<< "${git_status_output}")
  if [[ $(grep '^.[MADRCU]' <<< "${git_status_output}") ]]; then # Unstaged
    git_color="${bold_red}"
    git_char=" ${red}${SCM_DIRTY_CHAR}${normal}"
  elif [[ $(grep '^[MADRCU] ' <<< "${git_status_output}") ]]; then # uncommitted
    git_color="${bold_yellow}"
    git_char=" ${yellow}^${normal}"
  elif [[ $(grep '^\?\?' <<< "${git_status_output}") ]]; then # untracked
    git_color="${bold_cyan}"
    git_char=" ${cyan}+${normal}"
  elif [[ ! $(grep '^.' <<< "${git_status_output}") ]]; then # nothing to commit
    git_color="${bold_green}"
    git_char=" ${green}${SCM_CLEAN_CHAR}${normal}"
  fi

  local ahead_re='.+ahead ([0-9]+).+'
  local behind_re='.+behind ([0-9]+).+'
  [[ "${git_status_branch}" =~ ${ahead_re} ]] && SCM_GIT_AHEAD="|${yellow}${SCM_GIT_AHEAD_CHAR}${BASH_REMATCH[1]}${normal}"
  [[ "${git_status_branch}" =~ ${behind_re} ]] && SCM_GIT_BEHIND="|${green}${SCM_GIT_BEHIND_CHAR}${BASH_REMATCH[1]}${normal}"
  local stash_count="$(git stash list | wc -l | tr -d ' ')"
  [[ "${stash_count}" -gt 0 ]] && SCM_GIT_STASH=" {${stash_count}}"
  echo "${git_color}$(scm_prompt_info)${normal}${SCM_GIT_AHEAD}${SCM_GIT_BEHIND}${SCM_GIT_STASH}${git_char}"
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
  #SCM_CHANGE=$(git rev-parse HEAD 2>/dev/null)
  local g="$(git rev-parse --git-dir)"
  if [ -n "$g" ]; then
    local b=''
    local operation=''
    local step=''
    local total=''
    if [ -d "$g/rebase-merge" ]; then
      local ref="$(cat "$g/rebase-merge/head-name")"
      SCM_BRANCH=${ref#refs/heads/};
      step=$(cat "$g/rebase-merge/msgnum")
      total=$(cat "$g/rebase-merge/end")
      if [ -f "$g/rebase-merge/interactive" ]; then
        operation="REBASE-i"
      else
        operation="REBASE-m"
      fi
    else
      local ref=$(git symbolic-ref HEAD 2> /dev/null);
      SCM_BRANCH=${ref#refs/heads/};
      if [ -d "$g/rebase-apply" ]; then
        step=$(cat "$g/rebase-apply/next")
        total=$(cat "$g/rebase-apply/last")
        if [ -f "$g/rebase-apply/rebasing" ]; then
          operation="REBASE"
        elif [ -f "$g/rebase-apply/applying" ]; then
          operation="AM"
        else
          operation="AM/REBASE"
        fi
      elif [ -f "$g/MERGE_HEAD" ]; then
        operation="MERGE"
      elif [ -f "$g/CHERRY_PICK_HEAD" ]; then
        operation="CHERRY-PICK"
      elif [ -f "$g/REVERT_HEAD" ]; then
        operation="REVERT"
      elif [ -f "$g/BISECT_LOG" ]; then
        operation="BISECT"
      fi
      if [ -z "$SCM_BRANCH" ]; then
        #SCM_BRANCH="$(git describe --contains HEAD)" || SCM_BRANCH="$(cut -c1-7 "$g/HEAD" 2>/dev/null)..." || SCM_BRANCH="unknown"
        #SCM_BRANCH="$(git describe --contains --all HEAD)" || SCM_BRANCH="$(cut -c1-7 "$g/HEAD" 2>/dev/null)..." || SCM_BRANCH="unknown"
        #SCM_BRANCH="$(git describe HEAD)" || SCM_BRANCH="$(cut -c1-7 "$g/HEAD" 2>/dev/null)..." || SCM_BRANCH="unknown"
        SCM_BRANCH="$(git describe --tags --exact-match HEAD 2>/dev/null)" || SCM_BRANCH="$(cut -c1-7 "$g/HEAD" 2>/dev/null)..." || SCM_BRANCH="unknown"
        SCM_BRANCH="($SCM_BRANCH)"
      fi
    fi
    if [ -n "$step" ] && [ -n "$total" ]; then
      operation="${operation}[${step}/${total}]"
    fi
    if [ -n "$operation" ]; then
      SCM_BRANCH="${operation}:${SCM_BRANCH}"
    fi
  else
    local ref=$(git symbolic-ref HEAD 2> /dev/null);
    SCM_BRANCH=${ref#refs/heads/};
  fi

}

# vim: set ts=2 sw=2 et: #
