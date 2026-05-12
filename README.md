# ISO USB Flasher AppImage project

A Tkinter GUI wrapper for creating bootable USB drives from ISO files.

## Features

- Choose an ISO file in a GUI.
- Choose a target block device from `lsblk`.
- Enter sudo password in the GUI; it is passed once to `sudo -S` and then cleared from the field.
- Auto mode:
  - Windows installer ISO: creates GPT + FAT32 USB, copies files, and splits `sources/install.wim` into `.swm` chunks using `wimlib-imagex`.
  - Non-Windows ISO: falls back to raw `dd` writing.
- Explicit Windows mode and raw dd mode.

## Host dependencies

Runtime dependencies on the Linux host:

```bash
sudo apt install python3 python3-tk coreutils util-linux parted dosfstools rsync wimtools
```

`wimtools` provides `wimlib-imagex`, needed for Windows ISOs with a large `install.wim`.

## Run without building AppImage

```bash
./iso-flasher.AppDir/AppRun
```

## Build a real AppImage

Install `appimagetool`, then:

```bash
./build_appimage.sh
```

Output:

```text
ISO-USB-Flasher-x86_64.AppImage
```

## Important safety notes

- The selected USB device is erased.
- For Windows installer ISOs, raw `dd` often does not produce a usable installer USB. The Windows path uses FAT32 file-copy and `install.wim` splitting.
- The sudo password is not stored, but passing it through a GUI process is still less ideal than PolicyKit. For production, use `pkexec` with a proper policy file.
