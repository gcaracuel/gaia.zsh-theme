# oh-my-zsh Gaia Theme
# 
# This theme is used in a environemtn where multiple Java, NodeJS, Python virtualenvs and multiple Kubernetes cluster is managed, using diff version so to have a clear picture on you current version you will have them in screen.
# For most of the users just Python virtualenv and Kubernetes PROMPT integrayion will make sense.
#
# Git prompt is always active.
# Feature flags:
#   GAIA_THEME_NVM_SHOW=true|false to enable display/hide nvm active version
#   GAIA_THEME_JAVA_SHOW=true|false to enable display/hide java version
#   GAIA_THEME_VENV_SHOW=true|false to enable display/hide Python virtualenv active environment
#   GAIA_THEME_RUBY_SHOW=true|false to enable display/hide ruby active version
#   GAIA_THEME_K8S_SHOW=true|false to enable display/hide Kubernetes active cluster and namespace
#   GAIA_THEME_TF_SHOW=true|false to enable display/hide Terraform active workspace. Logo of Terraform not yet at Hack Fonts so we will use a bridge
#   GAIA_THEME_GCP_SHOW=true|false to enable display/hide Google Cloud active configuration. Use 'gcloud config ocnfigurations' to get more details
#

### NVM
GAIA_THEME_NVM_SHOW="${GAIA_THEME_NVM_SHOW:-false}"
ZSH_THEME_NVM_PROMPT_PREFIX="%{$fg_no_bold[green]%}\ue718 %{$fg_no_bold[white]%}"
ZSH_THEME_NVM_PROMPT_SUFFIX=" "

### JAVA version
GAIA_THEME_JAVA_SHOW="${GAIA_THEME_JAVA_SHOW:-false}"
GAIA_THEME_JAVA_BINARY="/usr/bin/java"
GAIA_THEME_JAVA_PROMPT_PREFIX="%{$fg_no_bold[white]%}\ue256 %{$fg_no_bold[white]%}"
GAIA_THEME_JAVA_PROMPT_SUFFIX=" "

### VIRTUALENV
GAIA_THEME_VENV_SHOW="${GAIA_THEME_VENV_SHOW:-false}"
GAIA_THEME_VENV_PROMPT_PREFIX="%{$fg_no_bold[green]%}\ue235 %{$fg_no_bold[white]%}"
GAIA_THEME_VENV_PROMPT_SUFFIX=" "

### RUBY (RVM/RBENV/CHRUBY)
GAIA_THEME_RUBY_SHOW="${GAIA_THEME_RUBY_SHOW:-false}"
GAIA_THEME_RUBY_PROMPT_PREFIX="%{$fg_no_bold[red]%}\ue791 %{$fg_no_bold[white]%}"
GAIA_THEME_RUBY_PROMPT_SUFFIX=" "

### Kubernetes
GAIA_THEME_K8S_SHOW="${GAIA_THEME_K8S_SHOW:-false}"
KUBE_PS1_BINARY="${KUBE_PS1_BINARY:-/usr/bin/kubectl}"
KUBE_PS1_PREFIX="%{$fg_no_bold[blue]%}⎈ %{$fg_no_bold[white]%}"
KUBE_PS1_SUFFIX=" "

### Google Cloud
GAIA_THEME_K8S_SHOW="${GAIA_THEME_GCP_SHOW:-false}"
GCP_PS1_BINARY="${GCP_PS1_BINARY:-/usr/local/bin/gcloud}"
GCP_PS1_PREFIX="%{$fg_no_bold[white]%}\ue7b2 %{$fg_no_bold[white]%}"
GCP_PS1_SUFFIX=" "

### Terraform
GAIA_THEME_TF_SHOW="${GAIA_THEME_TF_SHOW:-false}"
TF_PS1_BINARY="${TF_PS1_BINARY:-/usr/local/bin/terraform}"
TF_PS1_PREFIX="%{$fg_no_bold[cyan]%}\u032A %{$fg_no_bold[cyan]%}"
TF_PS1_SUFFIX=" "

### Git [±master ▾●]
ZSH_THEME_GIT_PROMPT_PREFIX="[%{$fg_bold[green]%}±%{$reset_color%}%{$fg_bold[white]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}]"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg_bold[green]%}✓%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_AHEAD="%{$fg[cyan]%}▴%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_BEHIND="%{$fg[magenta]%}▾%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_STAGED="%{$fg_bold[green]%}●%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNSTAGED="%{$fg_bold[yellow]%}●%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg_bold[red]%}●%{$reset_color%}"

gaia_git_branch () {
  ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
  ref=$(command git rev-parse --short HEAD 2> /dev/null) || return
  echo "${ref#refs/heads/}"
}

gaia_git_status() {
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

java_prompt_info () {
        [[ -f "$GAIA_THEME_JAVA_BINARY" ]] || return
        JAVA_PROMPT_VERSION=$($GAIA_THEME_JAVA_BINARY -version 2>&1 | awk -F '"' '/version/ {print $2}')
        echo "${GAIA_THEME_JAVA_PROMPT_PREFIX}${JAVA_PROMPT_VERSION}${GAIA_THEME_JAVA_PROMPT_SUFFIX}%{$reset_color%}"
}

k8s_prompt_info () {
        [[ $GAIA_THEME_K8S_SHOW == false ]] && return # Security trigger to save CPU time
        [[ -f "$KUBE_PS1_BINARY" ]] || return
        # cluster
        KUBE_PS1_CLUSTER=$(${KUBE_PS1_BINARY} config current-context 2>/dev/null)
        # namespace
        KUBE_PS1_NAMESPACE=$(${KUBE_PS1_BINARY} config view --minify --output 'jsonpath={..namespace}' 2>/dev/null)
        # Set namespace to 'default' if it is not defined
        KUBE_PS1_NAMESPACE="${KUBE_PS1_NAMESPACE:-default}"
        echo "${KUBE_PS1_PREFIX}${KUBE_PS1_CLUSTER}/${KUBE_PS1_NAMESPACE}${KUBE_PS1_SUFFIX}%{$reset_color%}"
}

gcloud_prompt_info () {
        [[ $GAIA_THEME_GCP_SHOW == false ]] && return # Security trigger to save CPU time
        [[ -f "$GCP_PS1_BINARY" ]] || return
        #workspace
        GCP_PS1_CONFIGURATION=$(${GCP_PS1_BINARY} config configurations list --filter 'is_active=true' --format="value(name)" 2>/dev/null)
        echo "${GCP_PS1_PREFIX}${GCP_PS1_CONFIGURATION}${GCP_PS1_SUFFIX}%{$reset_color%}"
}

tf_prompt_info () {
        [[ $GAIA_THEME_TF_SHOW == false ]] && return # Security trigger to save CPU time
        [[ -f "$TF_PS1_BINARY" ]] || return
        #workspace
        TF_PS1_WORKSPACE=$(${TF_PS1_BINARY} workspace show 2>/dev/null)
        echo "${TF_PS1_PREFIX}${TF_PS1_WORKSPACE}${TF_PS1_SUFFIX}%{$reset_color%}"
}

nvm_prompt_info () {
        [[ -f "$NVM_DIR/nvm.sh" ]] || return
        local nvm_prompt
        nvm_prompt=$(node -v 2>/dev/null)
        [[ "${nvm_prompt}x" = "x" ]] && return
        nvm_prompt=${nvm_prompt:1}
        echo "${ZSH_THEME_NVM_PROMPT_PREFIX}${nvm_prompt}${ZSH_THEME_NVM_PROMPT_SUFFIX}%{$reset_color%}"
}

gaia_git_prompt () {
  local _branch=$(gaia_git_branch)
  local _status=$(gaia_git_status)
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

gaia_java_prompt() {
  [[ $GAIA_THEME_JAVA_SHOW == false ]] && return
  echo -n "$(java_prompt_info)"
}

gaia_k8s_prompt() {
  [[ $GAIA_THEME_K8S_SHOW == false ]] && return
  echo -n "$(k8s_prompt_info)"
}

gaia_k8s_aliases() {
  alias kubeon='GAIA_THEME_K8S_SHOW=true'
  alias kubeoff='GAIA_THEME_K8S_SHOW=false'
}

gaia_tf_prompt() {
  [[ $GAIA_THEME_TF_SHOW == false ]] && return
  echo -n "$(tf_prompt_info)"
}

gaia_gcp_prompt() {
  [[ $GAIA_THEME_GCP_SHOW == false ]] && return
  echo -n "$(gcloud_prompt_info)"
}

gaia_nvm_prompt() {
  [[ $GAIA_THEME_NVM_SHOW == false ]] && return
  echo -n "$(nvm_prompt_info)"
}

gaia_venv_prompt() {
  [[ $GAIA_THEME_VENV_SHOW == false ]] && return

  # Check if the current directory running via Virtualenv
  [ -n "$VIRTUAL_ENV" ] && $(type deactivate >/dev/null 2>&1) || return
  echo -n "${GAIA_THEME_VENV_PROMPT_PREFIX}$(basename $VIRTUAL_ENV)${GAIA_THEME_VENV_PROMPT_SUFFIX}%{$reset_color%}"
}

gaia_ruby_prompt() {
  [[ $GAIA_THEME_RUBY_SHOW == false ]] && return

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
  echo -n "${GAIA_THEME_RUBY_PROMPT_PREFIX}${ruby_version}${GAIA_THEME_RUBY_PROMPT_SUFFIX}%{$reset_color%}"
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

gaia_precmd () {
  _1SPACES=`get_space $_1LEFT $_1RIGHT`
  print
  print -rP "$_1LEFT$_1SPACES$_1RIGHT"
}

# Load aliases
gaia_k8s_aliases

setopt prompt_subst
PROMPT='> $_LIBERTY '
RPROMPT='$(gaia_k8s_prompt)$(gaia_tf_prompt)$(gaia_gcp_prompt)$(gaia_java_prompt)$(gaia_nvm_prompt)$(gaia_venv_prompt)$(gaia_ruby_prompt)$(gaia_git_prompt)%{$reset_color%}'

autoload -U add-zsh-hook
add-zsh-hook precmd gaia_precmd
