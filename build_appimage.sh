#!/usr/bin/env bash
set -euo pipefail

APPDIR="iso-flasher.AppDir"
APPIMAGE_TOOL="./appimagetool-x86_64.AppImage"
OUTPUT_NAME="RGS-ISO-Flasher-x86_64.AppImage"

chmod +x "$APPDIR/AppRun"
chmod +x "$APPDIR/usr/bin/iso-flasher-gui"
chmod +x "$APPDIR/usr/bin/iso-flasher-runner"

sed -i 's/\r$//' "$APPDIR/usr/bin/iso-flasher-gui"
sed -i 's/\r$//' "$APPDIR/usr/bin/iso-flasher-runner"
sed -i 's/\r$//' "$APPDIR/AppRun"

if [[ ! -f "$APPIMAGE_TOOL" ]]; then
  echo "Downloading appimagetool..."
  wget -O "$APPIMAGE_TOOL" \
    https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage
  chmod +x "$APPIMAGE_TOOL"
fi

rm -f "$OUTPUT_NAME"

ARCH=x86_64 "$APPIMAGE_TOOL" "$APPDIR"

GENERATED="$(find . -maxdepth 1 -name '*.AppImage' ! -name 'appimagetool-x86_64.AppImage' | head -n 1)"

if [[ -z "$GENERATED" ]]; then
  echo "No AppImage generated."
  exit 1
fi

mv "$GENERATED" "$OUTPUT_NAME"
chmod +x "$OUTPUT_NAME"

echo "Built: $OUTPUT_NAME"
