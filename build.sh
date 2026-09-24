#!/bin/bash

set -e

echo "Installing Flutter..."

git clone https://github.com/flutter/flutter.git --depth 1 --branch stable /opt/flutter

export PATH="/opt/flutter/bin:$PATH"

flutter --version

flutter config --enable-web

flutter pub get

flutter build web --release

echo "Flutter web build completed!"