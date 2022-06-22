os="$(uname | awk '{print tolower($1)}')"
arch=$(uname -m)
# check if this is a work or home machine
function work() {
   [[ $os == "darwin" ]] && security find-certificate -c "OutSystems JSS Built-in Certificate Authority" &> /dev/null
}

# set path to include /usr/local
export PATH=/usr/local/bin:${PATH}
# and the admin tools that are there
export PATH=/usr/local/sbin:${PATH}

if [[  $arch == 'arm64' ]]; then
  export PATH=/opt/homebrew/bin:/opt/homebrew/sbin/:${PATH}
fi

# linux brew on linux
if [[ $os == "linux"  ]]; then
  brew_prefix="/home/linuxbrew/.linuxbrew"
  export PATH=${brew_prefix}/bin:${brew_prefix}/sbin:${PATH} >>~/.profile
fi

# XCode now puts all of it's dependencies under /Developer
# TODO: Update this for newer versions of Xcode
export PATH=/Developer/usr/bin:${PATH}

# Default Mac location
if [[ $os == "darwin" ]]; then
  export JAVA_HOME=$(/usr/libexec/java_home -v 15)
  # Developer command-line tools
  export PATH=${PATH}:/Developer/Tools
fi

# Developer command-line tools
export PATH=${PATH}:/Developer/Tools

# use specific AWS profile on work computers
if work; then 
  export AWS_PROFILE=sa
fi

# use Amazon EC2 command-line tools
# TODO: Modify for installing via homebrew
export EC2_HOME=/opt/ec2
export PATH=${EC2_HOME}/bin:${PATH}

# make sure PB Copy uses UTF-8
export __CF_USER_TEXT_ENCODING=0x1F5:0x8000100:0x8000100

# set various editor variables to use atom
export EDITOR="vi"
export VISUAL="vi"
export SVN_EDITOR="${VISUAL}"
export GIT_EDITOR="${VISUAL}"

# code in Go and run downloaded/installed packages
export GOPATH=/usr/local/lib/go
export PATH=${GOPATH}/bin:${PATH}

# use my home directory copy of commands before anything else
export PATH=${HOME}/bin:${PATH}

# Pivotal Network downloads via API require a key
export PIVNET_TOKEN=3Q-w2Xd34yU2VzdUXGJJ

# Pivotal CF command-line customization
export CF_COLOR=true

# set man paths to include /usr/local (brew and more) and MacPorts files
export MANPATH=/usr/local/man:${MANPATH}
export MANPATH=/opt/local/man:${MANPATH}
[[ $os == "darwin" ]] && export MANPATH=$(brew --prefix):${MANPATH}


# Use minicoda for Python 2.7
export PATH=/usr/local/opt/miniconda2/bin:$PATH

# rbnenv
export PATH=~/.rbenv/shims:${PATH}
export DOCKER_HOST=unix:///var/run/docker.sock
export DOCKER_HOST=unix:///var/run/docker.sock
export VCENTER_LICENSE=5H491-8CK8Q-K8392-008R0-0M541

# Use gettext from Homebrew
[[ $os == "darwin" ]] && export PATH=$(brew --prefix)/gettext/bin:$PATH

# manage kubectl plugins with `krew`
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# homelab GOVC configuration
if [[ $os == "darwin" ]] && security find-generic-password -a administrator@shortrib.local -s vcenter.lab.shortrib.net -w >&| /dev/null ; then
  export GOVC_URL=https://vcenter.lab.shortrib.net
  export GOVC_USERNAME=administrator@shortrib.local
  export GOVC_PASSWORD=$(security find-generic-password -a administrator@shortrib.local -s vcenter.lab.shortrib.net -w)
  export GOVC_INSECURE=true
fi
# Add .NET Core SDK tools
export PATH="${PATH}:${HOME}/.dotnet/tools"
export DOTNET_ROOT=/usr/local/Cellar/dotnet/3.1.110/libexec 
# rust
export PATH="${HOME}/.cargo/bin:${PATH}"

# use virtualenvwrapper
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/workspace

if [[ -d /opt/oracle/instantclient_19_8 ]]; then
  export ORACLE_HOME=/opt/oracle
  export PATH=${ORACLE_HOME}/instantclient_19_8:${PATH}
  export LD_LIBRARY_PATH=${ORACLE_HOME}/instantclient_19_8:${LD_LIBRARY_PATH}
fi

[[ $os == "darwin" ]] && export CERTBOT_ROOT=$(brew --prefix)/etc/certbot

if [[ -d ${HOME}/.cargp ]] ; then
  . "$HOME/.cargo/env"
fi

export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)

if [[ -d ${HOME}/.rd ]] ; then
  export PATH=${PATH}:"$HOME/.rd/bin"
fi
