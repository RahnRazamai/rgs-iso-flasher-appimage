# RGS ISO Flasher

A modern Linux GUI utility for creating bootable USB drives from ISO files.

Built for simplicity, portability, and Steam Deck/Linux compatibility.

---

## Features

- Simple graphical interface
- Browse and select ISO files
- Detect and select USB drives automatically
- Supports Windows installer ISOs
- Supports Linux ISOs
- Automatic Windows `install.wim` splitting using `wimlib`
- Raw `dd` flashing mode for Linux images
- AppImage portable distribution
- SteamOS and Steam Deck compatible
- Sudo authentication directly in the app

---

## Supported Modes

### Auto Mode
Automatically detects the ISO type:

- **Windows ISO**
  - Creates GPT + FAT32 USB
  - Copies installer files
  - Splits large `install.wim` into `.swm` chunks

- **Linux ISO**
  - Uses raw `dd` flashing

### Manual Modes

- Windows Installer Mode
- Raw `dd` Mode

---

## Screenshots

<img width="952" height="759" alt="Screenshot_20260514_102809" src="https://github.com/user-attachments/assets/2c77d1e7-b389-4760-ba64-ca1f21a5b39d" />

---

## Linux Host Dependencies

The AppImage bundles Python 3.12, Tkinter, and Tcl/Tk. You do not need to
install Python or Tk to open it. The flashing operations still use the host's
system tools and `sudo`.

### Ubuntu / Debian

```bash
sudo apt install sudo coreutils util-linux parted dosfstools rsync wimtools systemd
```

### Arch / SteamOS

```bash
sudo pacman -S sudo coreutils util-linux parted dosfstools rsync wimlib systemd
```

---

## Running Without AppImage

Running from the source checkout requires host Python and Tkinter. Install
`python3 python3-tk` on Ubuntu/Debian or `python tk` on Arch/SteamOS first.

```bash
./iso-flasher.AppDir/AppRun
```

---

## Building the AppImage

Build on an x86_64 Linux host with Bash, `curl`, `sha256sum`, and standard
coreutils installed:

```bash
./build_appimage.sh
```

The script downloads and verifies pinned Python, appimagetool, and static
AppImage runtime assets. It stages a complete application in `.build/` and
writes `RGS-ISO-Flasher-x86_64.AppImage` in the repository root. It works from
any current directory and does not require FUSE or host Python/Tkinter.
When upgrading an asset, update its URL/version and SHA-256 checksum together
in `build_appimage.sh`.

Do not package the source `iso-flasher.AppDir` directly with appimagetool: the
build script must first add the portable runtime.

Check the packaged window on a desktop:

```bash
bash tests/smoke_appimage.sh
```

For headless CI, install `xvfb` and `xauth`, then run
`xvfb-run -a bash tests/smoke_appimage.sh`. This test replaces host Python with
a failing stub, overrides host Python/Tcl settings, and opens the real window
for 15 seconds through each launch path. Disk discovery is stubbed; it does
not flash any device. GitHub Actions builds, tests, and uploads the AppImage.

Every push to `main` or `master` (including a pull request merge) also publishes
the tested artifact and its SHA-256 checksum in a GitHub release tagged
`build-<workflow run number>`, marked as the latest release. The tag points to
the exact commit that was built. Publishing uses the repository's automatic
`GITHUB_TOKEN`; no extra secret is required. Pull requests and manual workflow
runs only build and test. Rerunning an already published build preserves the
existing release and its assets.

---

## Running the AppImage

```bash
chmod +x RGS-ISO-Flasher-x86_64.AppImage
./RGS-ISO-Flasher-x86_64.AppImage
```

If AppImage mounting fails:

```bash
./RGS-ISO-Flasher-x86_64.AppImage --appimage-extract-and-run
```

Or extract it manually:

```bash
./RGS-ISO-Flasher-x86_64.AppImage --appimage-extract
cd squashfs-root
./AppRun
```

---

## Safety Notes

- The selected USB device will be completely erased.
- Always verify the correct USB device before flashing.
- Windows ISOs require special handling; raw `dd` alone is often not bootable.
- Passwords are not stored permanently.
- Future releases may migrate to PolicyKit (`pkexec`) for improved security.

---

## Compatibility

The packaged Python runtime targets x86_64 Linux with glibc 2.17 or newer
and a working X11 display (or XWayland). Standard desktop X11/font libraries
are still provided by the host. The static AppImage runtime includes
libfuse, so system `libfuse2` is not required. FUSE mounting support is needed
for normal execution; extraction mode works without it.

Tested on:

- Ubuntu
- Arch Linux
- SteamOS
- Steam Deck
- Fedora

After the automatic GitHub release has published successfully, comment `/retest`
on the AppImage catalog pull request. Retesting before updating the release
would test the old artifact again.

---

## License

MIT License

---

## Roadmap

- Progress bar
- Dark mode
- Drag & drop ISO support
- Secure PolicyKit authentication
- Persistent Linux live USB support
- Multi-language support
