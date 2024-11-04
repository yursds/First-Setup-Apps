#!/bin/bash

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# File path
LIST='./list/flatpak_apps.txt'

# Arrays to hold the status of applications
installed_apps=()
not_installed_apps=()

# Function to check if a package is installed and install it if not
check_and_install() {
    if dpkg -l | grep -q "$1"; then
        echo -e "${GREEN}$1 is already installed.${NC}"
    else
        echo -e "${GREEN}Installing $1...${NC}"
        sudo apt install -y "$1"
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}$1 installation successful.${NC}"
            installed_apps+=("$1")
        else
            echo -e "${RED}Error installing $1.${NC}"
            not_installed_apps+=("$1")
        fi
    fi
}

# Install Flatpak and GNOME Software plugin for Flatpak
check_and_install flatpak
check_and_install gnome-software-plugin-flatpak

# Add Flathub repository
echo -e "${GREEN}Adding Flathub repository...${NC}"
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Flathub repository added successfully.${NC}"
else
    echo -e "${RED}Error adding Flathub repository.${NC}"
fi

# Prepare the options for Zenity checklist
zenity_options=()
while IFS=: read -r app description; do
    # Skip empty lines and lines starting with #
    if [[ -z "$app" || $app =~ ^# ]]; then
        continue
    fi
    app=$(echo $app | xargs) # trim leading/trailing whitespace
    description=$(echo $description | xargs)
    zenity_options+=("FALSE" "$app" "$description")
done < ${LIST}

# Use zenity to select applications
apps_selected=$(zenity --list \
    --title="Select Applications to Install" \
    --checklist \
    --column="Install" \
    --column="Application" \
    --column="Description" \
    "${zenity_options[@]}" \
    --separator=" " \
    --width=600 \
    --height=400 \
)

# Check if the user pressed Cancel or closed the dialog
if [ $? -eq 1 ]; then
    echo -e "${RED}Operation cancelled.${NC}"
    exit 1
fi

# Install selected applications
for app in $apps_selected; do
    echo -e "${GREEN}Installing $app...${NC}"
    flatpak install flathub "$(echo $app | cut -d ':' -f 1)" -y
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}$app installation successful.${NC}"
        installed_apps+=("$app")
    else
        echo -e "${RED}Error installing $app.${NC}"
        not_installed_apps+=("$app")
    fi
done

# Summary of installed and not installed applications
if [ ${#installed_apps[@]} -ne 0 ]; then
    echo -e "\nInstalled applications:"
    for app in "${installed_apps[@]}"; do
        echo -e "- $app"
    done
fi

if [ ${#not_installed_apps[@]} -ne 0 ]; then
    echo -e "\n${RED}Not installed applications:${NC}"
    for app in "${not_installed_apps[@]}"; do
        echo -e "${RED}- $app${NC}"
    done
fi

echo -e "\n${GREEN}Done!${NC}"

