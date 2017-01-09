#!/bin/sh

/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"




mas install 880001334   # reeder
mas install 451907568   # paprika
brew cask install garmin-express



mas install 715768417   # microsoft remote desktop
mas install 1055511498  # day one
mas install 1046095491  # freeze



# install pre-built packages using caskroom


# brew cask install caffeine
brew cask install candybar



# Screen recording tools

brew cask install recordit
brew cask install skitch
brew cask install licecap
brew cask install screenflow

brew cask install utorrent
mas install 403388562   # transmit
brew install wget
brew cask install pacifist




# install packages to build
brew install autoconf
brew install automake



brew install cmake
brew install direnv

brew install fftw
brew install gettext


brew install jenkins
brew install jq

brew install libgpg-error
brew install libksba
brew install libogg
brew install libsndfile
brew install libtool
brew install libvorbis
brew install libyaml

brew install portaudio
brew install dsd
brew install itpp
brew install mbelib





brew install pkg-config






# MS Office *sigh*
curl -o ${TMPDIR}msoffice.pkg http://go.microsoft.com/fwlink/?LinkId=524176
installer -pkg ${TMPDIR}msoffice.pkg -target /
rm ${TMPDIR}/msoffice.pkg
