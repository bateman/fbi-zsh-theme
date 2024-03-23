# oh-my-zsh FBI Theme based on Bureau Theme

SEGMENT_SEPARATOR="\ue0b0"
SEGMENT_SEPARATOR_YELLOW="\033[33m\033[44m${SEGMENT_SEPARATOR}\033[0m"
SEGMENT_SEPARATOR_BLUE="\033[34m${SEGMENT_SEPARATOR}\033[0m"

### NVM

ZSH_THEME_NVM_PROMPT_PREFIX="%B⬡%b "
ZSH_THEME_NVM_PROMPT_SUFFIX=""

### Git [±master ▾●]

ZSH_THEME_GIT_PROMPT_PREFIX="[%{$fg_bold[green]%}±%{$reset_color%}%{$fg_bold[white]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}]"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg_bold[green]%}✓%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_AHEAD="%{$fg[cyan]%}▴%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_BEHIND="%{$fg[magenta]%}▾%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_STAGED="%{$fg_bold[green]%}●%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNSTAGED="%{$fg_bold[yellow]%}●%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg_bold[red]%}●%{$reset_color%}"

bureau_git_branch () {
  local ref
  ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
  ref=$(command git rev-parse --short HEAD 2> /dev/null) || return
  echo "${ref#refs/heads/}"
}

bureau_git_status() {
  local result gitstatus

  # check status of files
  gitstatus=$(command git status --porcelain -b 2> /dev/null)
  if [[ -n "$gitstatus" ]]; then
    if $(echo "$gitstatus" | command grep -q '^[AMRD]. '); then
      result+="$ZSH_THEME_GIT_PROMPT_STAGED"
    fi
    if $(echo "$gitstatus" | command grep -q '^.[MTD] '); then
      result+="$ZSH_THEME_GIT_PROMPT_UNSTAGED"
    fi
    if $(echo "$gitstatus" | command grep -q -E '^\?\? '); then
      result+="$ZSH_THEME_GIT_PROMPT_UNTRACKED"
    fi
    if $(echo "$gitstatus" | command grep -q '^UU '); then
      result+="$ZSH_THEME_GIT_PROMPT_UNMERGED"
    fi
  else
    result+="$ZSH_THEME_GIT_PROMPT_CLEAN"
  fi

  # check status of local repository
  if $(echo "$gitstatus" | command grep -q '^## .*ahead'); then
    result+="$ZSH_THEME_GIT_PROMPT_AHEAD"
  fi
  if $(echo "$gitstatus" | command grep -q '^## .*behind'); then
    result+="$ZSH_THEME_GIT_PROMPT_BEHIND"
  fi
  if $(echo "$gitstatus" | command grep -q '^## .*diverged'); then
    result+="$ZSH_THEME_GIT_PROMPT_DIVERGED"
  fi

  if $(command git rev-parse --verify refs/stash &> /dev/null); then
    result+="$ZSH_THEME_GIT_PROMPT_STASHED"
  fi

  echo $result
}

bureau_git_prompt() {
  local gitbranch=$(bureau_git_branch)
  local gitstatus=$(bureau_git_status)
  local info

  if [[ -z "$gitbranch" ]]; then
    return
  fi

  info="${gitbranch:gs/%/%%}"

  if [[ -n "$gitstatus" ]]; then
    info+=" $gitstatus"
  fi

  echo "${ZSH_THEME_GIT_PROMPT_PREFIX}${info}${ZSH_THEME_GIT_PROMPT_SUFFIX}"
}


_PATH="%{$bg_bold[blue]$fg[white]%}%~%{$reset_color%}"

if [[ $EUID -eq 0 ]]; then
  _USERNAME="%{$fg_bold[red]%}%n"
  _LIBERTY="%{$fg[red]%}#"
else
  _USERNAME="%{$bg_bold[yellow]$fg_bold[white]%}%n"
  _LIBERTY="%{$fg[blue]%}$"
fi
_USERNAME="$_USERNAME@%m%{$reset_color%}"
_LIBERTY="$_LIBERTY%{$reset_color%}"


_PRECMD=$(echo -e "${_USERNAME}${SEGMENT_SEPARATOR_YELLOW}${_PATH}${SEGMENT_SEPARATOR_BLUE}")

bureau_precmd () {
  print
  print -rP "${_PRECMD}"
}

setopt prompt_subst
PROMPT='> $_LIBERTY '
RPROMPT='$(nvm_prompt_info) $(bureau_git_prompt)'

autoload -U add-zsh-hook
add-zsh-hook precmd bureau_precmd

