#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$ROOT/.build"
DOWNLOADS="$BUILD_DIR/downloads"
OUTPUT_NAME="$ROOT/RGS-ISO-Flasher-x86_64.AppImage"

[[ "$(uname -m)" == x86_64 ]] || { echo "Build on an x86_64 Linux host." >&2; exit 1; }
for command in curl sha256sum; do
  command -v "$command" >/dev/null || { echo "Missing build dependency: $command" >&2; exit 1; }
done

mkdir -p "$DOWNLOADS"
WORK="$(mktemp -d "$BUILD_DIR/package.XXXXXX")"
trap 'rm -rf -- "$WORK"' EXIT

# Verify cached files too. Update the version/URL and checksum together.
download() {
  local url="$1" destination="$2" checksum="$3"
  if [[ ! -f "$destination" ]]; then
    curl --fail --location --retry 3 "$url" -o "$WORK/download"
    printf '%s  %s\n' "$checksum" "$WORK/download" | sha256sum --check --status
    mv -- "$WORK/download" "$destination"
  fi
  printf '%s  %s\n' "$checksum" "$destination" | sha256sum --check
}

# manylinux2014 keeps the Python payload compatible with glibc >= 2.17.
# This distribution includes _tkinter, Tcl/Tk shared libraries and Tcl scripts.
PYTHON_IMAGE="$DOWNLOADS/python3.12.15-manylinux2014-x86_64.AppImage"
download \
  "https://github.com/niess/python-appimage/releases/download/python3.12/python3.12.15-cp312-cp312-manylinux2014_x86_64.AppImage" \
  "$PYTHON_IMAGE" \
  a6a9bf619a3e21c5623be144d8ac4e458e1a5b5c133b1cc99b142d6e71b82c76

APPIMAGE_TOOL="$DOWNLOADS/appimagetool-1.9.1.AppImage"
download \
  "https://github.com/AppImage/appimagetool/releases/download/1.9.1/appimagetool-x86_64.AppImage" \
  "$APPIMAGE_TOOL" \
  ed4ce84f0d9caff66f50bcca6ff6f35aae54ce8135408b3fa33abfc3cb384eb0

# The modern static runtime includes libfuse; do not use AppImageKit's old runtime.
RUNTIME="$DOWNLOADS/runtime-20251108-x86_64"
download \
  "https://github.com/AppImage/type2-runtime/releases/download/20251108/runtime-x86_64" \
  "$RUNTIME" \
  2fca8b443c92510f1483a883f60061ad09b46b978b2631c807cd873a47ec260d
chmod +x "$PYTHON_IMAGE" "$APPIMAGE_TOOL"

# Stage the runtime separately so its launcher cannot overwrite our APPDIR.
APPDIR="$WORK/iso-flasher.AppDir"
mkdir -p "$APPDIR/usr/lib"
(
  cd "$WORK"
  "$PYTHON_IMAGE" --appimage-extract > python-extract.log
)
mv -- "$WORK/squashfs-root" "$APPDIR/usr/lib/rgs-python"
# Runtime extraction creates private directories. The packed filesystem is
# owned by root, so make its contents readable/traversable by desktop users.
chmod -R a+rX "$APPDIR/usr/lib/rgs-python"
cp -a "$ROOT/iso-flasher.AppDir/." "$APPDIR/"
rm -f "$APPDIR/usr/bin/iso-flasher-gui.save"
for script in AppRun usr/bin/iso-flasher-gui usr/bin/iso-flasher-runner; do
  sed -i 's/\r$//' "$APPDIR/$script"
  chmod +x "$APPDIR/$script"
done

# Fail the build if the portable interpreter or Tk payload is incomplete.
TCL_LIBRARY="$APPDIR/usr/lib/rgs-python/usr/share/tcltk/tcl8.6" \
  "$APPDIR/usr/lib/rgs-python/opt/python3.12/bin/python3.12" -I -c \
  'import tkinter, _tkinter; from tkinter import ttk, filedialog, messagebox; print("Bundled Tcl:", tkinter.Tcl().eval("info patchlevel"))'

# Extraction mode also allows builds on hosts/CI without FUSE.
ARCH=x86_64 "$APPIMAGE_TOOL" --appimage-extract-and-run \
  --runtime-file "$RUNTIME" "$APPDIR" "$WORK/RGS-ISO-Flasher-x86_64.AppImage"
mv -- "$WORK/RGS-ISO-Flasher-x86_64.AppImage" "$OUTPUT_NAME"
chmod +x "$OUTPUT_NAME"
echo "Built: $OUTPUT_NAME"
