# set path to include /usr/local
export PATH=/usr/local/bin:${PATH}
# and the admin tools that are there
export PATH=/usr/local/sbin:${PATH}

if [[  `uname -m` == 'arm64' ]]; then
  export PATH=/opt/homebrew/bin:/opt/homebrew/sbin/:${PATH}
fi

# XCode now puts all of it's dependencies under /Developer
# TODO: Update this for newer versions of Xcode
export PATH=/Developer/usr/bin:${PATH}

# Default Mac location
export JAVA_HOME=$(/usr/libexec/java_home -v 11.0.4)

# set man paths to include /usr/local (brew and more) and MacPorts files
export MANPATH=/usr/local/man:${MANPATH}
export MANPATH=/opt/local/man:${MANPATH}
if [[  `uname -m` == 'arm64' ]]; then
  export MANPATH=/opt/homebrew/man:${MANPATH}
fi

# Developer command-line tools
export PATH=${PATH}:/Developer/Tools

# use ant from MacPorts installation
# TODO: Modify for installing via homebrew
export ANT_HOME=/opt/local/share/java/apache-ant
export PATH=${PATH}:${ANT_HOME}/bin

# use Amazon EC2 command-line tools
# TODO: Modify for installing via homebrew
export EC2_HOME=/opt/ec2
export PATH=${EC2_HOME}/bin:${PATH}

# use Amazon ELB command-line tools
export AWS_ELB_HOME=/opt/elb
export PATH=${AWS_ELB_HOME}/bin:${PATH}

# make sure PB Copy uses UTF-8
export __CF_USER_TEXT_ENCODING=0x1F5:0x8000100:0x8000100

# set various editor variables to use atom
export EDITOR="vi"
export VISUAL="vi"
export SVN_EDITOR="${VISUAL}"
export GIT_EDITOR="${VISUAL}"

# use Pivotal Shared billing AWS environment
export PIVOTAL_AWS_ACCESS_KEY_ID=$(aws configure get --profile pivotal aws_access_key_id)
export PIVOTAL_AWS_SECRET_ACCESS_KEY=$(aws configure get --profile pivotal aws_secret_access_key)
export AWS_ACCESS_KEY_ID=${PIVOTAL_AWS_ACCESS_KEY_ID}
export AWS_SECRET_ACCESS_KEY=${PIVOTAL_AWS_SECRET_ACCESS_KEY}

# use personal billing AWS environment
export PERSONAL_AWS_ACCESS_KEY_ID=$(aws configure get --profile personal aws_accces_key_id)
export PERSONAL_AWS_SECRET_ACCESS_KEY=$(aws configure get --profile personal aws_access_key_id)

# code in Go and run downloaded/installed packages
export GOPATH=/usr/local/lib/go
export PATH=${GOPATH}/bin:${PATH}

# use my home directory copy of commands before anything else
export PATH=${HOME}/bin:${PATH}

# Pivotal Network downloads via API require a key
export PIVNET_TOKEN=3Q-w2Xd34yU2VzdUXGJJ

# Pivotal CF command-line customization
export CF_COLOR=true

# Use Geode installed from Homebrew
export GEODE_HOME=/usr/local/Cellar/apache-geode/1.0.0-incubating.M3/libexec

# Use minicoda for Python 2.7
export PATH=/usr/local/opt/miniconda2/bin:$PATH

# Use gettext from Homebrew
export PATH=/usr/local/opt/gettext/bin:$PATH

# CF Jump stuff outside of my home directory
export CFJ_HOME=${HOME}/.cfj

# rbnenv
export PATH=~/.rbenv/shims:${PATH}
export DOCKER_HOST=unix:///var/run/docker.sock
export DOCKER_HOST=unix:///var/run/docker.sock
export GLASSFISH_HOME=/usr/local/opt/glassfish/libexec
export PATH="${PATH}:${GLASSFISH_HOME}/bin"
export VCENTER_LICENSE=5H491-8CK8Q-K8392-008R0-0M541

os="$(uname | awk '{print tolower($1)}')"
# linunx brew on linux
if [[ $os == "linux"  ]]; then
  brew_prefix="/home/linuxbrew/.linuxbrew"
  export PATH=${brew_prefix}/bin:${brew_prefix}/sbin:${PATH} >>~/.profile
fi

export PIVOTAL_USER=cdantonio

# manage kubectl plugins with `krew`
export PATH="${PATH}:${HOME}/.krew/bin"

# homelab GOVC configuration
export GOVC_URL=https://vcenter.lab.crdant.net
export GOVC_USERNAME=administrator@crdant.net
export GOVC_PASSWORD=$(security find-generic-password -a administrator@crdant.net -s vcenter.lab.crdant.net -w)
export GOVC_INSECURE=true
# Add .NET Core SDK tools
export PATH="${PATH}:${HOME}/.dotnet/tools"
export DOTNET_ROOT=/usr/local/Cellar/dotnet/3.1.110/libexec 
# rust
export PATH="${HOME}/.cargo/bin:${PATH}"
