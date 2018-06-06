# oh-my-zsh Bureau Theme

### NVM

BUREAU_THEME_NVM_SHOW="${BUREAU_THEME_NVM_SHOW:-true}"
ZSH_THEME_NVM_PROMPT_PREFIX="%{$fg_no_bold[green]%}⬡ %{$fg_bold[cyan]%} "
ZSH_THEME_NVM_PROMPT_SUFFIX=" "

### VIRTUALENV

BUREAU_THEME_VENV_SHOW="${BUREAU_THEME_VENV_SHOW:-true}"
BUREAU_THEME_VENV_PROMPT_PREFIX="%{$fg_no_bold[green]%}⟆ %{$fg_bold[cyan]%}"
BUREAU_THEME_VENV_PROMPT_SUFFIX=" "

### RUBY (RVM/RBENV/CHRUBY)

BUREAU_THEME_RUBY_SHOW="${BUREAU_THEME_RUBY_SHOW:-true}"
BUREAU_THEME_RUBY_PROMPT_PREFIX="%{$fg_no_bold[red]%}💎 %{$fg_bold[cyan]%}"
BUREAU_THEME_RUBY_PROMPT_SUFFIX=" "

### Kubernetes
BUREAU_THEME_K8S_SHOW="${BUREAU_THEME_K8S_SHOW:-true}"
KUBE_PS1_BINARY="${KUBE_PS1_BINARY:-/usr/bin/kubectl}"
KUBE_PS1_PREFIX="%{$fg_no_bold[blue]%}⎈ %{$fg_bold[cyan]%}"
KUBE_PS1_SUFFIX=" "

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
  ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
  ref=$(command git rev-parse --short HEAD 2> /dev/null) || return
  echo "${ref#refs/heads/}"
}

bureau_git_status() {
  _STATUS=""

  # check status of files
  _INDEX=$(command git status --porcelain 2> /dev/null)
  if [[ -n "$_INDEX" ]]; then
    if $(echo "$_INDEX" | command grep -q '^[AMRD]. '); then
      _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_STAGED"
    fi
    if $(echo "$_INDEX" | command grep -q '^.[MTD] '); then
      _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_UNSTAGED"
    fi
    if $(echo "$_INDEX" | command grep -q -E '^\?\? '); then
      _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_UNTRACKED"
    fi
    if $(echo "$_INDEX" | command grep -q '^UU '); then
      _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_UNMERGED"
    fi
  else
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_CLEAN"
  fi

  # check status of local repository
  _INDEX=$(command git status --porcelain -b 2> /dev/null)
  if $(echo "$_INDEX" | command grep -q '^## .*ahead'); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_AHEAD"
  fi
  if $(echo "$_INDEX" | command grep -q '^## .*behind'); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_BEHIND"
  fi
  if $(echo "$_INDEX" | command grep -q '^## .*diverged'); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_DIVERGED"
  fi

  if $(command git rev-parse --verify refs/stash &> /dev/null); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_STASHED"
  fi

  echo $_STATUS
}

k8s_prompt_info () {
        [[ -f "$KUBE_PS1_BINARY" ]] || return
        # namespace
        KUBE_PS1_NAMESPACE=$(${KUBE_PS1_BINARY} config view --minify --output 'jsonpath={..namespace}' 2>/dev/null)
        # Set namespace to 'default' if it is not defined
        KUBE_PS1_NAMESPACE="${KUBE_PS1_NAMESPACE:-default}"
        echo "${KUBE_PS1_PREFIX}${KUBE_PS1_NAMESPACE}${KUBE_PS1_SUFFIX}%{$reset_color%}"
}

nvm_prompt_info () {
        [[ -f "$NVM_DIR/nvm.sh" ]] || return
        local nvm_prompt
        nvm_prompt=$(node -v 2>/dev/null)
        [[ "${nvm_prompt}x" = "x" ]] && return
        nvm_prompt=${nvm_prompt:1}
        echo "${ZSH_THEME_NVM_PROMPT_PREFIX}${nvm_prompt}${ZSH_THEME_NVM_PROMPT_SUFFIX}"
}

bureau_git_prompt () {
  local _branch=$(bureau_git_branch)
  local _status=$(bureau_git_status)
  local _result=""
  if [[ "${_branch}x" != "x" ]]; then
    _result="$ZSH_THEME_GIT_PROMPT_PREFIX$_branch"
    if [[ "${_status}x" != "x" ]]; then
      _result="$_result $_status"
    fi
    _result="$_result$ZSH_THEME_GIT_PROMPT_SUFFIX"
  fi
  echo $_result
}

bureau_k8s_prompt() {
  [[ $BUREAU_THEME_K8S_SHOW == false ]] && return
  echo -n "$(k8s_prompt_info)"
}

bureau_nvm_prompt() {
  [[ $BUREAU_THEME_NVM_SHOW == false ]] && return
  echo -n "$(nvm_prompt_info)"
}

bureau_venv_prompt() {
  [[ $BUREAU_THEME_VENV_SHOW == false ]] && return

  # Check if the current directory running via Virtualenv
  [ -n "$VIRTUAL_ENV" ] && $(type deactivate >/dev/null 2>&1) || return
  echo -n "${BUREAU_THEME_VENV_PROMPT_PREFIX}$(basename $VIRTUAL_ENV)${BUREAU_THEME_VENV_PROMPT_SUFFIX}%{$reset_color%}"
}

bureau_ruby_prompt() {
  [[ $BUREAU_THEME_RUBY_SHOW == false ]] && return

  if command -v rvm-prompt > /dev/null 2>&1; then
    if rvm gemset list | grep "=> (default)" > /dev/null 2>&1; then
      ruby_version=$(rvm-prompt i v g)
    fi
  elif command -v chruby > /dev/null 2>&1; then
    ruby_version=$(chruby | sed -n -e 's/ \* //p')
  elif command -v rbenv > /dev/null 2>&1; then
    ruby_version=$(rbenv version | sed -e 's/ (set.*$//')
  else
    return
  fi
  echo -n "${BUREAU_THEME_RUBY_PROMPT_PREFIX}${ruby_version}${BUREAU_THEME_RUBY_PROMPT_SUFFIX}%{$reset_color%}"
}


_PATH="%{$fg_bold[white]%}%~%{$reset_color%}"

if [[ $EUID -eq 0 ]]; then
  _USERNAME="%{$fg_bold[red]%}%n"
  _LIBERTY="%{$fg[red]%}#"
else
  _USERNAME="%{$fg_bold[white]%}%n"
  _LIBERTY="%{$fg[green]%}$"
fi
_USERNAME="$_USERNAME%{$reset_color%}@%m"
_LIBERTY="$_LIBERTY%{$reset_color%}"


get_space () {
  local STR=$1$2
  local zero='%([BSUbfksu]|([FB]|){*})'
  local LENGTH=${#${(S%%)STR//$~zero/}}
  local SPACES=""
  (( LENGTH = ${COLUMNS} - $LENGTH - 1))

  for i in {0..$LENGTH}
    do
      SPACES="$SPACES "
    done

  echo $SPACES
}

_1LEFT="$_USERNAME $_PATH"
_1RIGHT="[%*] "

bureau_precmd () {
  _1SPACES=`get_space $_1LEFT $_1RIGHT`
  print
  print -rP "$_1LEFT$_1SPACES$_1RIGHT"
}

setopt prompt_subst
PROMPT='> $_LIBERTY '
RPROMPT='$(bureau_k8s_prompt)$(bureau_nvm_prompt)$(bureau_venv_prompt)$(bureau_ruby_prompt)$(bureau_git_prompt)'


autoload -U add-zsh-hook
add-zsh-hook precmd bureau_precmd
