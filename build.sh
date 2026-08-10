#!/bin/bash
set -e

# Download lightweight pre-compiled Flutter SDK if not present
if [ ! -d "$HOME/flutter" ]; then
  echo "Downloading Flutter SDK..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 $HOME/flutter
fi

export PATH="$PATH:$HOME/flutter/bin"

echo "Checking Flutter installation..."
flutter --version

echo "Building Flutter Web application..."
flutter pub get
flutter build web --release --no-pub
