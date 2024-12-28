# Applications for Fast Setup on Ubuntu

## Overview

This script helps in installing various applications on Ubuntu using the `apt` package manager. The list of apps are in the folder `list` that contains `apt_apps.txt`. The script provides an option to install **All Apps** at once or to **Specific Apps** using a graphical interface with `zenity`.  
At the end a list of additional application useful that you have to download from official sites.


## Table of Contents 
- [Overview](#overview) 
- [Prerequisites](#prerequisites) 
- [Usage](#usage) 
   - [Clone of repository](#clone-of-repository) 
   - [Installation](#installation) 
   - [Uninstallation](#uninstallation) 
- [List of apps](#list-of-apps) 
- [Additional Recommended Apps](#additional-recommended-apps)

## Prerequisites
Installed by default on Ubuntu system:

- `apt` package manager;
- `zenity` for the graphical interface.

In addition:

- `git-all` to clone this repository.
   ```bash
   sudo apt-get install git-all
   ```

## Usage
The following commands should be run from the main directory, which is named `First_Setup_Apps`.

1. **Follow the Prompts**:
	Choose whether to install all applications or select specific ones through the graphical interface.

1. **Check the Summary**:
   The script will provide a summary of installed and not installed applications after execution.


### Clone of repository
Run in the terminal:
   ```bash
   git clone https://github.com/yursds/First_Setup_Apps.git
   cd First_Setup_Apps
   ```

### Installation

Run in the terminal from main folder `First_Setup_Apps`:
   ```bash
   ./install_apt.sh
   ```

### Uninstallation
Run in the terminal from main folder `First_Setup_Apps`:
   ```bash
   ./uninstall_apt.sh
   ```

## List of apps

- System Tools 
   - **htop**: Interactive process viewer 
   - **neofetch**: System information tool 
   - **terminator**: Terminal emulator 
   - **timeshift**: System restore tool 
- Media and Editing
   - **vlc**: Media player 
   - **cheese**: Simple application for webcam
   - **gimp**: Image editor 
   - **kdenlive**: Video editor 
- PDF Tools 
   - **krop**: PDF cropping tool 
   - **pdfarranger**: PDF file manipulation
- GNOME Extensions 
   - **gnome-shell-extensions**: Collection of shell extensions for GNOME 
   - **gnome-shell-extension-manager**: Manage GNOME Shell extensions 
   - **gnome-tweaks**: Tweak tool for GNOME 
- Development Tools
   - **tree**: tool to see directory structure of a path

## Additional Recommended Apps
For more fast first setup the following packages are not included in the installation list.
For a faster first setup, the following packages are not included in the installation list.

For LaTeX users, the recommended applications are the following:
   - LaTeX Tools
      - **klatexformula**: LaTeX formula editor 
      - **texstudio**: LaTeX editor
      - **texlive-full**: Comprehensive TeX system  
      
         **ATTENTION**  
         When installing `texlive-full`, as reported in this [issue](https://bugs.launchpad.net/ubuntu/+source/context/+bug/2058409), the process may get stuck at:

         ```bash
         Pregenerating ConTeXt MarkIV format. This may take some time...
         ```
         to resolve this, simply press the Enter button multiple times.

From official sites, it is recommended to install the following *must-have* applications:

   - [**code**](https://code.visualstudio.com/): Visual Studio Code;
   - [**inkscape**](https://inkscape.org/): Vector graphics editor;
   - [**ferdium**](https://ferdium.org/): Organizer of favorite cllient apps.
   - [**spotify**](https://www.spotify.com/it/download/linux/): Music player.