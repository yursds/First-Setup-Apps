# Applications for Fast Setup on Ubuntu

## Table of Contents 
- [Overview](#overview) 
   - [List of apps](#list-of-apps) 
- [Prerequisites](#prerequisites) 
- [Usage](#usage) 
   - [Clone of repository](#clone-of-repository) 
   - [Installation](#installation) 
   - [Uninstallation](#uninstallation) 
- [Additional Recommended Apps and Steps](#additional-recommended-apps-and-steps)

## Overview

This script helps in installing various applications on Ubuntu using the `apt` package manager.  
The list of apps is in `apt_apps.txt`.  
The script provides an option to install **All Apps** or **Specific Apps** using a graphical interface with `zenity`.

**NOTE**: After installation you can remove the folder `First-Setup-Apps`.

### List of apps

- System Tools 
   - **htop**: Interactive process viewer (simple)
   - **btop**: Interactive process viewer (CPU, RAM, Disk, Network)
   - **nvtop**: Interactive process viewer (support NVIDIA GPU)
   - **neofetch**: System information tool 
   - **terminator**: Terminal emulator 
   - **timeshift**: System restore tool [OPTIONAL]
   - **rclone**: Tool to synchronize a Linux directory with cloud storage services [[link]](https://copilot.microsoft.com/chats/Q8tYhyV1BQHUBjo9DWgQU)
- Media and Editing
   - **vlc**: Media player 
   - **cheese**: Simple application for webcam [OPTIONAL]
   - **gimp**: Image editor [OPTIONAL]
   - **kdenlive**: Video editor [OPTIONAL]
- PDF Tools 
   - **krop**: PDF cropping tool [OPTIONAL]
   - **pdfarranger**: PDF file manipulation [OPTIONAL]
- GNOME Extensions 
   - **gnome-shell-extensions**: Collection of shell extensions for GNOME 
   - **gnome-shell-extension-manager**: Manage GNOME Shell extensions 
   - **gnome-tweaks**: Tweak tool for GNOME 
- Development Tools
   - **tree**: Tool to see directory structure of a path
   - **dconf-editor**: Viewer and editor of applications internal settings. [ADVANCED]
- Extra
   - **oneko**: Try it! [OPTIONAL]

At the bottom of this page you can find [additional recommended applications](#additional-recommended-apps), that you can download from official sites.


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

### Clone of repository
Run in the terminal:
   ```bash
   git clone https://github.com/yursds/First_Setup_Apps.git
   cd First_Setup_Apps
   ```

---

The following commands should be run from the main directory, which is named `First_Setup_Apps`.

1. **Follow the Prompts**:
	Choose whether to install all applications or select specific ones through the graphical interface.

1. **Check the Summary**:
   The script will provide a summary of installed and not installed applications after execution.

### Installation

Run in the terminal from the main folder `First_Setup_Apps`:
   ```bash
   ./install_apt.sh
   ```

### Uninstallation
Run in the terminal from the main folder `First_Setup_Apps`:
   ```bash
   ./uninstall_apt.sh
   ```

## Additional Recommended Apps and Steps
For a faster first setup, the following packages are not included in the installation list.

- For LaTeX users, the recommended applications are the following:
   - LaTeX Tools
      - **klatexformula**: LaTeX formula editor [OPTIONAL];
      - **texstudio**: LaTeX editor [OPTIONAL];
      - **texlive-full**: Comprehensive TeX system [OPTIONAL];  
      
         **ATTENTION**  
         When installing `texlive-full`, as reported in this [issue](https://bugs.launchpad.net/ubuntu/+source/context/+bug/2058409), the process may get stuck at:

         ```bash
         Pregenerating ConTeXt MarkIV format. This may take some time...
         ```
         to resolve this, simply press the Enter button multiple times.

- From official sites, it is recommended to install the following *must-have* applications:

   - [**code**](https://code.visualstudio.com/): Visual Studio Code;
   - [**inkscape**](https://inkscape.org/): Vector graphics editor [OPTIONAL];
   - [**ferdium**](https://ferdium.org/): Organizer of favorite client apps;
   - [**WPS office**](https://it.wps.com/): suite office (compatible with MS office).

- For more robust authentication with GitHub, it is recommended using [**GitHub CLI**](https://github.com/cli/cli/blob/trunk/docs/install_linux.md). Follow the official instruction to complete the authentication. 

- For docker installation it is useful to follow the preliminaries instructions on the repository [**docker_ros_nvidia**](https://github.com/yursds/docker_ros_nvidia). [OLD VERSION]
