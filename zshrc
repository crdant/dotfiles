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
plugins=(git git-flow iterm2 tmux emoji docker aws brew minikube kubectl helm history-substring-search pasteboard velero terraform)

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

# check if this is a work or home machine

function work() {
   security find-certificate -c "OutSystems JSS Built-in Certificate Authority" &> /dev/null
}

# set up some named directories
function names {
  source=${1}
  if [ "$source" = "google" ] ; then
    inbox="/Volumes/GoogleDrive/My Drive/Inbox"
    outbox="/Volumes/GoogleDrive/My Drive/Outbox"
    pending="/Volumes/GoogleDrive/My Drive/Pending"
    read="/Volumes/GoogleDrive/My Drive/Read"
    watch="/Volumes/GoogleDrive/My Drive/Watch"
    archive="/Volumes/GoogleDrive/My Drive/Archive"
    projects="/Volumes/GoogleDrive/My Drive/Projects"
    accounts="/Volumes/GoogleDrive/My Drive/Archive/Accounts"
  elif [ "$source" = "onedrive" ] ; then 
    inbox="/Users/crdant/OneDrive - VMware, Inc/Inbox"
    outbox="/Users/crdant/OneDrive - VMware, Inc/Outbox"
    pending="/Users/crdant/OneDrive - VMware, Inc/Pending"
    read="/Users/crdant/OneDrive - VMware, Inc/Read"
    watch="/Users/crdant/OneDrive - VMware, Inc/Watch"
    archive="/Users/crdant/OneDrive - VMware, Inc/Archive"
    projects="/Users/crdant/OneDrive - VMware, Inc/Projects"
    accounts="/Users/crdant/OneDrive - VMware, Inc/Archive/Accounts"
  elif [ "$source" = "dropbox" ] ; then
    inbox=/Users/crdant/Dropbox/Inbox
    outbox=/Users/crdant/Dropbox/Outbox
    pending=/Users/crdant/Dropbox/Pending
    read=/Users/crdant/Dropbox/Read
    watch=/Users/crdant/Dropbox/Watch
    archive=/Users/crdant/Documents/Archive
    projects=/Users/crdant/Documents/Projects
    documents=/Users/crdant/Documents
    clients="/Users/crdant/Documents/Archive/Flying Mist/Clients"
  elif [ "$source" = "icloud" ] ; then
    inbox=/Users/crdant/Documents/Inbox
    outbox=/Users/crdant/Documents/Outbox
    pending=/Users/crdant/Documents/Pending
    read=/Users/crdant/Documents/Read
    watch=/Users/crdant/Documents/Watch
    archive=/Users/crdant/Documents/Archive
    projects=/Users/crdant/Documents/Projects
    documents=/Users/crdant/Documents
    accounts=/Users/crdant/Documents/Archives/Accounts
   else
    echo Using names from $NAMES_ARE_FROM_SOURCE
  fi

  # clients are for Pivotal clients who will only be on Drive
  clients="/Users/crdant/Google Drive/Archive/Clients"

  # same on all Macs I'm using
  documents=/Users/crdant/Documents
  src=/Users/crdant/workspace
  workspace=/Users/crdant/workspace
  idisk=/Volumes/iDisk
  export NAMES_ARE_FROM_SOURCE=$source
}

if work ; then
  names google
  demos=/Users/crdant/workspace/demos
  accounts=/Users/crdant/workspace/accounts
else
  names icloud
fi

# company directories
acquia=/Users/crdant/Documents/Archive/Acquia
hp=/Users/crdant/Documents/Archive/HP
systinet=/Users/crdant/Documents/Archive/Systinet
statestreet="/Users/crdant/Documents/Archive/State Street"
pivotal="/Users/crdant/Documents/Archive/Pivotal"

# merge several PDFs into one
function pdfcat {
    merged=${1} ;
    shift ;
    gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile=${1} $@
}

# extract PDF
function extract {
	first=${1}
	last=${2}
	python /System/Library/Automator/Extract\ Odd\ \&\ Even\ Pages.action/Contents/Resources/extract.py --input=${3} --output=${3}_${1}-${2}.pdf --slice [${1}:${2}]
}

# cdf: cd's to frontmost window of Finder
cdf ()
{
    currFolderPath=$( /usr/bin/osascript <<"    EOT"
        tell application "Finder"
            try
		set currFolder to (folder of the front window as alias)
            on error
		set currFolder to (path to desktop folder as alias)
            end try
            POSIX path of currFolder
        end tell
    EOT
    )
    cd "$currFolderPath"
}

# common aliases
alias more="less -X"
alias vim=nvim
alias vi=nvim
alias pd=pushd
alias pop=popd
alias ant="ant -find build.xml"
alias Ant="ant"
alias paste='curl -O `pbpaste`'
alias root-finder="sudo /System/Library/CoreServices/Finder.app/Contents/MacOS/Finder"
alias sha1="/usr/bin/openssl sha1"
alias rmd160="/usr/bin/openssl rmd160"
alias flushdns="dnscacheutil -flushcache"

# filetype aliases
alias -s txt=vimr
alias -s java=idea
alias -s xml=vimr
alias -s php=vimr
alias -s app=open

# check battery
alias battery="ioreg -l | grep Capacity"

# list all open sockets
alias lsock='sudo /usr/sbin/lsof -i -P'

# zipf: to create a ZIP archive of a folder
zipf () {
	zip -r "$1".zip "$1" ;
}

# enable Terminal proxy icons
update_terminal_cwd() {
    # Identify the directory using a "file:" scheme URL,
    # including the host name to disambiguate local vs.
    # remote connections. Percent-escape spaces.
    local SEARCH=' '
    local REPLACE='%20'
    local PWD_URL="file://$HOSTNAME${PWD//$SEARCH/$REPLACE}"
    printf '\e]7;%s\a' "$PWD_URL"
}
autoload add-zsh-hook
add-zsh-hook chpwd update_terminal_cwd
update_terminal_cwd

function op_secret () {
  local secret=${1}
  op get item ${secret} | jq -r '.details.fields[] | select ( .designation == "password" ) .value'
}

function hget () {
  local host="${1}"
  hostess dump | jq --raw-output --arg host $host '.[] | select ( .domain==$host ) .ip'
}


# add completions
# source /usr/local/share/zsh/site-functions/_go

# enable
export HOMEBREW_GITHUB_API_TOKEN=00628c278e94be1a37145eb3ee9b676f359740e7
eval "$(direnv hook zsh)"

# point cf at different instances
alias pws="cf login -a https://api.run.pivotal.io -u cdantonio@pivotal.io"
alias pez="cf login -a https://api.run.pcfbeta.io -sso"
alias pcd="cf login -a api.local.pcfdev.io --skip-ssl-validation -u admin"
alias lite="cf login --skip-ssl-validation -a https://api.bosh-lite.com -u admin"

# tabtab source for serverless package
# uninstall by removing these lines or running `tabtab uninstall serverless`
[[ -f /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/serverless.zsh ]] && . /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/serverless.zsh

# tabtab source for sls package
# uninstall by removing these lines or running `tabtab uninstall sls`
[[ -f /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/sls.zsh ]] && . /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/sls.zsh

# tabtab source for jhipster package
# uninstall by removing these lines or running `tabtab uninstall jhipster`
[[ -f /private/tmp/node_modules/tabtab/.completions/jhipster.zsh ]] && . /private/tmp/node_modules/tabtab/.completions/jhipster.zsh

# use homebrew python
export PATH=/usr/local/opt/python3/libexec/bin:${PATH}

complete -o nospace -C /usr/local/bin/mc mc
alias oni2='/Applications/Onivim2.app/Contents/MacOS/Oni2'

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

if [[  `uname -m` == 'arm64' ]]; then
  alias ibrew='arch --x86_64 /usr/local/bin/brew'
fi
