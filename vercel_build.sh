#!/usr/bin/env bash
set -euo pipefail

# Vercel build script for Flutter Web.
# It installs Flutter SDK (stable), enables web, and builds into build/web.

FLUTTER_VERSION="stable"
FLUTTER_DIR="$PWD/.flutter"

if [ ! -d "$FLUTTER_DIR" ]; then
  echo "[vercel_build] Installing Flutter ($FLUTTER_VERSION) into $FLUTTER_DIR";
  git clone --depth 1 --branch "$FLUTTER_VERSION" https://github.com/flutter/flutter.git "$FLUTTER_DIR"
else
  echo "[vercel_build] Flutter already present at $FLUTTER_DIR"
fi

export PATH="$FLUTTER_DIR/bin:$PATH"

flutter --version
flutter config --enable-web

# Fetch deps
flutter pub get

# Build web release
flutter build web --release

echo "[vercel_build] Build output: $PWD/build/web"