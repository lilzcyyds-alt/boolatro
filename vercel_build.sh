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

# Ensure Git LFS assets are present (Vercel's git checkout may contain LFS pointers only)
if command -v git-lfs >/dev/null 2>&1; then
  echo "[vercel_build] git-lfs already installed"
else
  echo "[vercel_build] Installing git-lfs (apt)"
  if command -v apt-get >/dev/null 2>&1; then
    apt-get update -y
    apt-get install -y git-lfs
  else
    echo "[vercel_build] WARNING: apt-get not available; skipping git-lfs install"
  fi
fi

if command -v git-lfs >/dev/null 2>&1; then
  git lfs install --local || true
  git lfs pull || true
fi

# Fetch deps
flutter pub get

# Build web release
GIT_SHA="$(git rev-parse --short HEAD 2>/dev/null || echo dev)"
BUILD_TIME="$(date -u +"%Y-%m-%dT%H:%MZ")"
flutter build web --release \
  --dart-define=GIT_SHA="$GIT_SHA" \
  --dart-define=BUILD_TIME="$BUILD_TIME"

echo "[vercel_build] Build output: $PWD/build/web"