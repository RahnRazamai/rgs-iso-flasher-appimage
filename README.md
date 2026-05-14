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

### Ubuntu / Debian

```bash
sudo apt install python3 python3-tk coreutils util-linux parted dosfstools rsync wimtools
```

### Arch / SteamOS

```bash
sudo pacman -S python tk parted dosfstools rsync wimlib ntfs-3g
```

---

## Running Without AppImage

```bash
./iso-flasher.AppDir/AppRun
```

---

## Building the AppImage

Download `appimagetool`:

```bash
wget https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage
chmod +x appimagetool-x86_64.AppImage
```

Build:

```bash
./build_appimage.sh
ARCH=x86_64 ./appimagetool-x86_64.AppImage iso-flasher.AppDir
```

---

## Running the AppImage

```bash
chmod +x RGS-ISO-Flasher-x86_64.AppImage
./RGS-ISO-Flasher-x86_64.AppImage
```

If AppImage mounting fails:

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

Tested on:

- Ubuntu
- Arch Linux
- SteamOS
- Steam Deck
- Fedora

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
