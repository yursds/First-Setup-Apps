# Install Applications for Fast Setup on Ubuntu

## Overview

This script helps in installing various applications on Ubuntu using the `apt` and `flatpak` package manager. The list of apps are in the folder `list` that contains `apt_apps.txt` and `flatpak_apps.txt`. The script provides an option to install all applications at once or to choose specific ones using a graphical interface with `zenity`. 

The file `install_flatpak.sh` is used also to configure [flathub](https://flathub.org/) on your system.

## Prerequisites
Installed by default on Ubuntu system:

- `apt` package manager
- `zenity` for the graphical interface
- `wget` for downloading files from the internet
- `gpg` for cryptographic security

## Usage
The following commands should be run from the main directory, which is named `first_setup`.

1. **Follow the Prompts**:
	Choose whether to install all applications or select specific ones through the graphical interface.

1. **Check the Summary**:
    The script will provide a summary of installed and not installed applications after execution.


### Installation
To install `apt` packages run in the terminal:
   ```bash
   ./install/install_apt.sh
   ```

**ATTENTION** When installing `texlive-full`, the process may get stuck at:
  ```bash
  Pregenerating ConTeXt MarkIV format. This may take some time...
  ```
As reported in this [issue](https://bugs.launchpad.net/ubuntu/+source/context/+bug/2058409), to resolve this, simply press the Enter button multiple times.

To configure `flathub` and install `flatpak` apps run in the terminal:
   ```bash
   ./install/install_flatpak.sh
   ```

### Uninstallation
To uninstall `apt` packages run in the terminal:
   ```bash
   ./uninstall/uninstall_apt.sh
   ```

To uninstall `flatpak` apps run in the terminal:
   ```bash
   ./uninstall/uninstall_flatpak.sh
   ```
To uninstall `flathub` run in the terminal:
   ```bash
  flatpak remote-delete flathub
   ```

## Customization 

1. **Prepare the `*.txt` File in `list` Folder**:
   - Format: 
     ```plaintext
     # Category
         application-name: description
     ```
   - Example:
     ```plaintext
     # System Tools
         htop: Interactive process viewer
         neofetch: System information tool
     ```

1. **Make the Script Executable**:
   ```bash
   chmod +x ./install/install_*.sh
   ```

1. **Run the Script**:
   ```bash
   ./install/install_*.sh
   ```

## List of apps

- System Tools 
   - **htop**: Interactive process viewer 
   - **neofetch**: System information tool 
   - **terminator**: Terminal emulator 
   - **timeshift**: System restore tool 
- Media 
   - **vlc**: Media player 
- Image and Video Editing 
   - **flameshot**: Screenshot tool 
   - **gimp**: Image editor 
   - **inkscape**: Vector graphics editor 
   - **kdenlive**: Video editor 
- PDF Tools 
   - **krop**: PDF cropping tool 
   - **pdfarranger**: PDF file manipulation 
- Communication 
   - **telegram-desktop**: Messaging app 
- GNOME Extensions 
   - **gnome-shell-extensions**: Collection of shell extensions for GNOME 
   - **gnome-shell-extension-manager**: Manage GNOME Shell extensions 
   - **gnome-tweaks**: Tweak tool for GNOME 
- LaTeX Tools 
   - **klatexformula**: LaTeX formula editor 
   - **texlive-full**: Comprehensive TeX system 
   - **texstudio**: LaTeX editor 
- Development Tools 
   - **git-all**: Complete set of Git tools 
   - **code**: Visual Studio Code 
- Collection of Apps 
   - **flatpak**: System for building, distributing, and running sandboxed desktop applications on Linux