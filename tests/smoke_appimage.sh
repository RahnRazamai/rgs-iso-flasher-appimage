#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
IMAGE="$(realpath -- "${1:-$ROOT/RGS-ISO-Flasher-x86_64.AppImage}")"
WORK="$(mktemp -d)"
trap 'rm -rf -- "$WORK"' EXIT

# Deliberately poison host Python and Tcl/Tk settings. A portable launcher must
# ignore these and must never run the python3 on PATH.
mkdir -p "$WORK/bin"
cat > "$WORK/bin/python3" <<'SH'
#!/bin/sh
echo 'ERROR: host Python was invoked' >&2
exit 1
SH
# Keep the startup test deterministic, with no disk discovery or disk writes.
cat > "$WORK/bin/lsblk" <<'SH'
#!/bin/sh
printf '{"blockdevices": []}\n'
SH
chmod +x "$WORK/bin/"*
export PATH="$WORK/bin:$PATH"
export PYTHONHOME=/nonexistent PYTHONPATH=/nonexistent
export TCL_LIBRARY=/nonexistent TK_LIBRARY=/nonexistent

# Test a relocated path with spaces, just as a catalog runner extracts the image.
mkdir -p "$WORK/relocated app"
(
  cd "$WORK/relocated app"
  "$IMAGE" --appimage-extract > /dev/null
)
APPDIR="$WORK/relocated app/squashfs-root"
PYTHON="$APPDIR/usr/lib/rgs-python/opt/python3.12/bin/python3.12"
env TCL_LIBRARY="$APPDIR/usr/lib/rgs-python/usr/share/tcltk/tcl8.6" \
  "$PYTHON" -I - "$APPDIR" <<'PY'
import pathlib
import sys
import tkinter
from tkinter import ttk, filedialog, messagebox

appdir = pathlib.Path(sys.argv[1])
assert pathlib.Path(sys.executable).is_relative_to(appdir)
assert pathlib.Path(tkinter.__file__).is_relative_to(appdir)
assert pathlib.Path(tkinter.Tcl().eval("info library")).is_relative_to(appdir)
assert (appdir / "usr/bin/iso-flasher-runner").is_file()
print("Bundled Python, Tkinter and Tcl verified")
PY

run_gui() {
  local log="$WORK/gui.log"
  timeout 30 "$@" --smoke-test > "$log" 2>&1 || { cat "$log"; return 1; }
  cat "$log"
  grep -Fxq 'GUI smoke test passed' "$log"
}

# Exercise both launcher paths: catalog-style extraction and the new runtime's
# extract-and-run mode (which requires no system libfuse2 or FUSE mount).
run_gui "$APPDIR/AppRun"
run_gui "$IMAGE" --appimage-extract-and-run
