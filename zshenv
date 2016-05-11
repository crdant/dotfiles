# set path to include /usr/local
export PATH=/usr/local/bin:${PATH}
# and the admin tools that are there
export PATH=/usr/local/sbin:${PATH}

# XCode now puts all of it's dependencies under /Developer
# TODO: Update this for newer versions of Xcode
export PATH=/Developer/usr/bin:${PATH}

# Oracle 1.8
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_77.jdk/Contents/Home

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

# use textmate to edit git commit messages, with a meaningful window title
export GIT_EDITOR="mate --name 'Git Commit Message' -w -l"

# setup BOSH lite for AWS
export BOSH_AWS_ACCESS_KEY_ID=AKIAIRW7G663QGREI3WA
export BOSH_AWS_SECRET_ACCESS_KEY=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%

# code in Go and run downloaded/installed packages
export GOPATH=/usr/local/lib/go
export PATH=${GOPATH}/bin:${PATH}

# use my home directory copy of commands before anything else
export PATH=${HOME}/bin:${PATH}

# Pivotal Network downloads via API require a key
export PIVNET_TOKEN=KgoMEtxmTZJsodLY4KUw

# Pivotal CF command-line customization
export CF_COLOR=true                     Do not colorize output
