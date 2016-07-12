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
plugins=(git git-flow textmate osx vagrant emoji golang gradle docker aws cf)

source $ZSH/oh-my-zsh.sh

# Customize to your needs...
# history settings
HISTSIZE=500
SAVEHIST=500
HISTFILE=~/.history

# set shell options
setopt emacs
setopt nobeep
setopt inc_append_history
setopt auto_cd
setopt bash_auto_list
setopt no_hup
setopt correct
setopt no_always_last_prompt
setopt complete_aliases
unsetopt hist_verify

# set up some named directories
function names {
  source=${1}
  if [ "$source" = "google" ] ; then
      inbox="/Users/crdant/Google Drive/Inbox"
      outbox="/Users/crdant/Google Drive/Outbox"
      pending="/Users/crdant/Google Drive/Pending"
      read="/Users/crdant/Google Drive/Read"
      archive="/Users/crdant/Google Drive/Archive"
      projects="/Users/crdant/Google Drive/Projects"
      clients="/Users/crdant/Google Drive/Archive/Clients"
  elif [ "$source" = "dropbox" ] ; then
    inbox=/Users/crdant/Dropbox/Inbox
    outbox=/Users/crdant/Dropbox/Outbox
    pending=/Users/crdant/Dropbox/Pending
    read=/Users/crdant/Dropbox/Read
    archive=/Users/crdant/Documents/Archive
    projects=/Users/crdant/Documents/Projects
    documents=/Users/crdant/Documents
    clients="/Users/crdant/Documents/Archive/Flying Mist/Clients"
  else
    echo Using names from $NAMES_ARE_FROM_SOURCE
  fi

  # clients are for Pivotal clients who will only be on Drive
  clients="/Users/crdant/Google Drive/Archive/Clients"

  # same on all Macs I'm using
  documents=/Users/crdant/Documents
  src=/Users/crdant/Source
  idisk=/Volumes/iDisk
  export NAMES_ARE_FROM_SOURCE=$source
}

if security find-certificate -c "Pivotal Root CA" &> /dev/null
then
  names google
else
  names dropbox
fi

# company directories
acquia=/Users/crdant/Documents/Archive/Acquia
hp=/Users/crdant/Documents/Archive/HP
systinet=/Users/crdant/Documents/Archive/Systinet
statestreet="/Users/crdant/Documents/Archive/State Street"
flyingmist="/Users/crdant/Documents/Archive/Flying Mist"
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

# run a terminal
rxt () {
    IDENT=${1}
    SERVER=${2}
    if [ "$HOST" = "panix5.panix.com" ] ; then
        XTERM="/usr/X11R6/bin/xterm"
    elif [ "$HOST" = "192.168.1.104" ] ; then
        XTERM="/usr/X11R6/bin/xterm"
    else
        XTERM="/usr/X/bin/xterm"
    fi
    ssh -f -l ${IDENT} -X ${SERVER} ${XTERM} -ls -sl 500 -sb -T "$IDENT@$SERVER" -n "$USERNAME@$SERVER" -fn 6x10
}

# run an instance of emacs via X
remacs () {
    USERNAME=${1}
    HOST=${2}
    ssh -f -l ${USERNAME} -X ${HOST} /usr/bin/emacs -T "$USERNAME:emacs@$HOST" -n "$USERNAME:emacs@$HOST" -fn 6x10
}

# tunnel in VNC
vnct () {
    HOST=${1}
    ssh -CN -L 5901:127.0.0.1:5900 ${HOST}
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
alias xterm="xterm -fn 6x10 -sl 500 -sb -ls"
alias more="less -X"
alias pd=pushd
alias pop=popd
alias ant="ant -find build.xml"
alias Ant="ant"
alias paste='curl -O `pbpaste`'
alias check="cvs update -dP 2>/dev/null"
alias root-finder="sudo /System/Library/CoreServices/Finder.app/Contents/MacOS/Finder"
alias sha1="/usr/bin/openssl sha1"
alias rmd160="/usr/bin/openssl rmd160"
alias flushdns="dnscacheutil -flushcache"

# filetype aliases
alias -s txt=mate
alias -s java=mate
alias -s xml=mate
alias -s php=mate
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

# add completions
# source /usr/local/share/zsh/site-functions/_go

# enable
export HOMEBREW_GITHUB_API_TOKEN=00628c278e94be1a37145eb3ee9b676f359740e7
eval "$(direnv hook zsh)"

# point cf at different instances
alias pws="cf login -a https://api.run.pivotal.io -u cdantonio@pivotal.io"
alias pez="cf login -a https://api.run.pez.pivotal.io -sso"
alias pcd="cf login -a api.local.pcfdev.io --skip-ssl-validation -u admin"
alias lite="cf login --skip-ssl-validation -a https://api.bosh-lite.com -u admin"
alias pcf=cf
