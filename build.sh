#!/bin/bash
# Clone Flutter SDK on Vercel build container if not present
if [ ! -d "flutter" ]; then
  echo "Cloning Flutter SDK..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1
fi

export PATH="$PATH:`pwd`/flutter/bin"

echo "Building Flutter Web application..."
flutter config --enable-web
flutter pub get
flutter build web --release
