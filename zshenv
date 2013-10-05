# set path to include /usr/local
export PATH=/usr/local/bin:${PATH}
# and the admin tools that are there
export PATH=/usr/local/sbin:${PATH}

# XCode now puts all of it's dependencies under /Developer
export PATH=/Developer/usr/bin:${PATH}

# Oracle JDK 1.7
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.7.0_10.jdk/Contents/Home

# set man paths to include /usr/local (brew and more) and MacPorts files
export MANPATH=/usr/local/man:${MANPATH}
export MANPATH=/opt/local/man:${MANPATH}

# Developer command-line tools
export PATH=${PATH}:/Developer/Tools

# use ant from MacPorts installation
export ANT_HOME=/opt/local/share/java/apache-ant
export PATH=${PATH}:${ANT_HOME}/bin

# use Amazon EC2 command-line tools
export EC2_HOME=/opt/ec2
export PATH=${EC2_HOME}/bin:${PATH}

# use Amazon ELB command-line tools
export AWS_ELB_HOME=/opt/elb
export PATH=${AWS_ELB_HOME}/bin:${PATH}

# make sure PB Copy uses UTF-8
export __CF_USER_TEXT_ENCODING=0x1F5:0x8000100:0x8000100

# enable the Google depot_tools for building Google open source (Chromium and Dash, at least)
export PATH=/opt/depot_tools:${PATH}

# use textmate to edit git commit messages, with a meaningful window title
export GIT_EDITOR="mate --name 'Git Commit Message' -w -l"

# use Ingall's Information Security Drupal scanner
export PATH=/Users/crdant/Source/iinfosec/titan:${PATH}

PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting

# use Grails from homebrew
export GRAILS_HOME=/usr/local/Cellar/grails/2.0.3/libexec
