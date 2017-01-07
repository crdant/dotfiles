#!/bin/sh

/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

brew tap homebrew/serivces

# install items from mac app store
brew tap argon/mas
brew install mas
mas install 409789998   # twitter
mas install 891953906   # buffer
mas install 880001334   # reeder
mas install 451907568   # paprika
mas install 747961939   # toad
mas install 451444120   # memory clean
mas install 403388562   # transmit
mas install 497799835   # xcode
mas install 1053031090  # boxy
mas install 1031444301  # hangouts plus
mas install 715768417   # microsoft remote desktop

# install iwork
mas install 409183694  # keynote
mas install 409203825  # numbers
mas install 409201541  # pages

# install pre-built packages using caskroom
brew cask install 0xed
brew cask install 1password
brew cask install alfred
brew cask install amazon-music
brew cask install atom
brew cask install audacity
brew cask install bartender
brew cask install bose-soundtouch
brew cask install caffeine
brew cask install candybar
brew cask install carbon-copy-cloner
brew cask install charles
brew cask install cocoapacketanalyzer
brew cask install dash
brew cask install dropbox
brew cask install docker
brew cask install dotnet
brew cask install evernote
brew cask install flux
brew cask install flycut
brew cask install garmin-express
brew cask install github-desktop
brew cask install google-chrome
brew cask install google-cloud-sdk
brew cask install google-drive
brew cask install grandperspective
brew cask install handbrake
brew cask install intellij-idea
brew cask install istumbler
brew cask install java
brew cask install kindle
brew cask instsall mysqlworkbench
brew cask install pacifist
brew cask install packer
brew cask install packetpeeper
brew cask install postman
brew cask install rubymine
brew cask install rstudio
brew cask install screenhero
brew cask install shiftit
brew cask install skitch
brew cask install skype
brew cask install slack
brew cask install spotify
brew cask install textexpander
brew cask install textmate
brew cask install torbrowser
brew cask install utorrent
brew cask install vagrant
brew cask install virtualbox
brew cask install wireshark
brew cask install zoomus

# install packages to build
brew install ack
brew install autoconf
brew install automake
brew install apache-geode
brew install awscli
brew install azure-cli
brew install cassandra
brew install cmake
brew install direnv
brew install dsd
brew install fftw
brew install flac
brew install gettext
brew install git-flow
brew install go
brew install godep
brew install gradle
brew install itpp
brew install jenkins
brew install jq
brew install libgpg-error
brew install libksba
brew install libogg
brew install libsndfile
brew install libtool
brew install libvorbis
brew install libyaml
brew install maven
brew install mbelib
brew install mongodb
brew install mysql
brew install nexus
brew install node
brew install openssl
brew install packer
brew install pianobar
brew install pkg-config
brew install portaudio
brew install postgresql
brew install python
brew install rbenv
brew install readline
brew install ruby-build
brew install rust
brew install springboot
brew install the_silver_searcher
brew install wget
brew install zsh-completions

# some fonts for coding
brew tap caskroom/fonts
brew cask install font-inconsolata
brew cask install font-fira-code
brew cask install font-bitstream-vera

# now some go stuff
go get -u github.com/cfmobile/gopivnet
go get -u github.com/cppforlife/packer-bosh
go get -u github.com/hashicorp/terraform

# add atom packages
apm install atom-beautify
apm install atom-keyboard-macros
apm install auto-update-packages
apm install councourse-vis
apm install docblockr
apm install editorconfig
apm install expose
apm install file-icons
apm install git-plus
apm install git-time-machine
apm install go-quick-import
apm install java-importer
apm install minimap
apm install pigments
apm install pretty-json
apm install todo-show

# MS Office *sigh*

# CLOUD FOUNDRY
# install bosh from the CF tap
brew tap cloudfoundry/tap
brew install bosh-cli

# install pivotal CF CLI rather than the open source version
brew tap pivotal/tap
brew install cf-cli
brew install git-pair
brew install gemfire

# install PCF dev
pcfdev_releases=https://network.pivotal.io/api/v2/products/pcfdev/releases
pcfdev_eula=`curl -qsLf -H "Authorization: Token $PIVNET_TOKEN" $pcfdev_releases | jq --raw-output ".releases[0] ._links .eula_acceptance .href"`
pcfdev_eula_accepted=`curl -qsLf -X POST -d "" -H "Authorization: Token $PIVNET_TOKEN" $eula_url | jq --raw-output '.accepted_at'`
pcfdev_files_url=`curl -qsLf -H "Authorization: Token $PIVNET_TOKEN" "$pcfdev_releases" | jq --raw-output ".releases[0] ._links .product_files .href"`
pcfdev_post_url=`curl -qsLf -H "Authorization: Token $PIVNET_TOKEN" $pcfdev_files_url | jq --raw-output ".product_files[] | select( .aws_object_key | contains(\"osx\") ) ._links .download .href"`
pcfdev_download_url=`curl -qsLf -X POST -d "" -H "Accept: application/json" -H "Content-Type: application/json" -H "Authorization: Token $PIVNET_TOKEN" $pcfdev_post_url -w "%{url_effective}\n"`
curl -qsLf -o ${TMPDIR}/pcfdev-osx.zip $pcfdev_download_url
pushd ${TMPDIR}
unzip -p ${TMPDIR}/pcfdev-osx.zip > pcfdev
chmod 755 pcfdev
yes | cf install-plugin pcfdev
rm ${TMPDIR}/pcfdev  ${TMPDIR}/pcfdev-osx.zip
popd
