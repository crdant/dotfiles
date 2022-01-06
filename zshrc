os="$(uname | awk '{print tolower($1)}')"
arch=$(uname -m)

# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="crdant"

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Comment this out to disable weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git git-flow gpg-agent tmux emoji docker aws minikube kubectl helm history-substring-search pasteboard velero terraform)
if [[ $os == "darwin" ]]; then
  plugins+=(iterm2 brew macos)
fi
source $ZSH/oh-my-zsh.sh

# Customize to your needs...
# history settings
HISTSIZE=500
SAVEHIST=500
HISTFILE=~/.history

# set shell options
setopt vi
setopt nobeep
setopt inc_append_history
setopt auto_cd
setopt bash_auto_list
setopt no_hup
setopt correct
setopt no_always_last_prompt
setopt complete_aliases
unsetopt hist_verify

# merge several PDFs into one
function pdfcat {
    merged=${1} ;
    shift ;
    gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile=${1} $@
}

# common aliases
alias more="less -X"
alias vim=nvim
alias vi=nvim
alias pd=pushd
alias pop=popd
alias sha1="/usr/bin/openssl sha1"
alias rmd160="/usr/bin/openssl rmd160"

# list all open sockets
alias lsock='sudo /usr/sbin/lsof -i -P'

# zipf: to create a ZIP archive of a folder
zipf () {
	zip -r "$1".zip "$1" ;
}

function op_secret () {
  local secret=${1}
  op get item ${secret} | jq -r '.details.fields[] | select ( .designation == "password" ) .value'
}

function hget () {
  local host="${1}"
  hostess dump | jq --raw-output --arg host $host '.[] | select ( .domain==$host ) .ip'
}

# tmux session handiness
function tmux-has-session() { 
  session=${1}
  tmux has-session -t ${session} 2>/dev/null 
}

function tmux-session() {
  session=${1}
  if tmux-has-session ${session}; then
    tmux attach -t ${session}
  else
    tmux new-session -s ${session} \; source-file "${HOME}/.tmux/sessions/${session}"
  fi
}

function fullscreen() {
  tmux-session fullscreen
} 

function window() {
  tmux-session window
} 

complete -o nospace -C /usr/local/bin/mc mc
eval "$(fly completion --shell zsh)"

if [[ $os == "darwin" ]]; then
  source ${HOME}/.dotfiles/zshrc.darwin
fi


