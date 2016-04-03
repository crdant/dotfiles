# install items from mac app store
brew tap argon/mas
mas install 409789998   # twitter
mas install 891953906   # buffer
mas install 880001334   # reeder
mas install 451907568   # paprika
mas install 747961939   # toad
mas install 451444120   # memory clean
mas install 403388562   # transmit
mas install 497799835   # xcode
mas install 1053031090  # boxy

# install iwork
mas install 409183694  # keynote
mas install 409203825  # numbers
mas install 409201541  # pages

# install pre-built packages using caskroom
brew cask install 0xed
brew cask install 1password
brew cask install alfred
brew cask install amazon-music
brew cask install atext
brew cask install atom
brew cask install audacity
brew cask install bartender
brew cask install caffeine
brew cask install candybar
brew cask install carbon-copy-cloner
brew cask install charles
brew cask install cocoapacketanalyzer
brew cask install dash
brew cask install dropbox 
brew cask install dockertoolbox
brew cask install evernote
brew cask install flux
brew cask install flycut
brew cask install garmin-express
brew cask install github-desktop
brew cask install google-chrome
brew cask install google-drive
brew cask install grandperspective
brew cask install handbrake
brew cask install intellij-idea
brew cask install istumbler
brew cask install kindle
brew cask install java
brew cask install pacifist
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

# install packages to build
brew install ack
brew install autoconf
brew install automake
brew install awscli
brew install cmake
brew install direnv
brew install dsd
brew install fftw
brew install flac
brew install git-flow
brew install go
brew install godep
brew install gradle
brew install itpp
brew install jenkins
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
brew install nexus
brew install node
brew install openssl
brew install packer
brew install pkg-config
brew install portaudio
brew install rbenv
brew install readline
brew install ruby-build
brew install springboot
brew install wget
brew install zsh-completions

# some fonts for coding
brew tap caskroom/fonts
brew cask install font-inconsolata
brew cask install font-fira-code
brew cask install font-bitstream-vera

# install pivotal CF rather than the open source version
brew tap pivotal/tap
brew install cf-cli

# now some go stuff
go get github.com/cfmobile/gopivnet
go install github.com/cfmobile/gopivnet
