#!/bin/sh

# Fail this script if any subcommand fails.
set -e

# The default execution directory of this script is the ci_scripts directory.
cd $CI_PRIMARY_REPOSITORY_PATH # change working directory to the root of your cloned repo.

# Add the Mapbox API key to the .netrc file.
echo -e "machine api.mapbox.com\nlogin mapbox\npassword sk.eyJ1IjoiYm9udW51MjAyIiwiYSI6ImNtMDlyazk2czE3ZmcyaXB5aDNodzYzOTUifQ.u_wO74HnITBXT96oI48lpw" > ~/.netrc
# Print the contents of the .netrc file.
cat ~/.netrc
# Print a success message.
echo "Mapbox API key added to the .netrc file."

# Install Flutter using git.
git clone https://github.com/flutter/flutter.git --depth 1 -b stable $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"

# Install Flutter artifacts for iOS (--ios), or macOS (--macos) platforms.
flutter precache --ios

# Install Flutter dependencies.
flutter pub get

# Install CocoaPods using Homebrew.
HOMEBREW_NO_AUTO_UPDATE=1 # disable homebrew's automatic updates.
brew install cocoapods

brew update

# Install CocoaPods dependencies.
cd ios && pod install # run `pod install` in the `ios` directory.

# Install Ruby using Homebrew (if not installed).
brew install ruby

# Ensure the gem binary path is in your PATH.
export PATH="/usr/local/lib/ruby/gems/3.0.0/bin:$PATH"

# Install Bundler (a gem for managing Ruby gems).
gem install bundler

# Create a Gemfile in the `ios` directory.
cd ios
echo 'source "https://rubygems.org"' > Gemfile
echo 'gem "xcodeproj", "1.24.0"' >> Gemfile

# Install the xcodeproj gem.
bundle install

exit 0
