#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
if ! command -v appimagetool >/dev/null 2>&1; then
  echo "appimagetool is required to build a real AppImage."
  echo "Install it from AppImageKit, then run: ARCH=x86_64 appimagetool iso-flasher.AppDir"
  exit 1
fi
ARCH=x86_64 appimagetool iso-flasher.AppDir ISO-USB-Flasher-x86_64.AppImage
