# set path to include /usr/local
export PATH=/usr/local/bin:${PATH}
# and the admin tools that are there
export PATH=/usr/local/sbin:${PATH}

# XCode now puts all of it's dependencies under /Developer
# TODO: Update this for newer versions of Xcode
export PATH=/Developer/usr/bin:${PATH}

# Default Mac location
export JAVA_HOME=/Library/Java/Home

# set man paths to include /usr/local (brew and more) and MacPorts files
export MANPATH=/usr/local/man:${MANPATH}
export MANPATH=/opt/local/man:${MANPATH}

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
export EDITOR="atom -w"
export VISUAL="atom -w"
export SVN_EDITOR="${VISUAL}"
export GIT_EDITOR="${VISUAL}"

# setup BOSH lite for AWS
export BOSH_AWS_ACCESS_KEY_ID=AKIAIRW7G663QGREI3WA
export BOSH_AWS_SECRET_ACCESS_KEY=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%

# use Pivotal Shared billing AWS environment
export PIVOTAL_AWS_ACCESS_KEY_ID=AKIAJSLN7RKMLJGUSXXQ
export PIVOTAL_AWS_SECRET_ACCESS_KEY=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
export AWS_ACCESS_KEY_ID=${PIVOTAL_AWS_ACCESS_KEY_ID}
export AWS_SECRET_ACCESS_KEY=${PIVOTAL_AWS_SECRET_ACCESS_KEY}

# use personal billing AWS environment
export PERSONAL_AWS_ACCESS_KEY_ID=AKIAJD6FY3VALDRKDBYA
export PERSONAL_AWS_SECRET_ACCESS_KEY=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

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
