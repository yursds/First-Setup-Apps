#!/bin/bash

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# File path
LIST='./apt_apps.txt'

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

# Read applications from the text file, skip empty lines and lines starting with '#'
mapfile -t apps_to_install < <(grep -vE '^(#|$)' ${LIST})

# Prepare the options for Zenity checklist
zenity_options=()

current_category=""
while IFS= read -r line; do
    # Skip empty lines
    if [[ -z "$line" ]]; then
        continue
    fi
    # Check for category lines
    if [[ $line =~ ^# ]]; then
        current_category=$(echo $line | sed 's/^# //')
    else
        name=$(echo $line | cut -d ':' -f 1)
        description=$(echo $line | cut -d ':' -f 2)
        if [[ -z "$description" ]]; then
            description="No description available"
        fi
        zenity_options+=("FALSE" "$name" "$current_category: $description")
    fi
done < ${LIST}

# Ask if the user wants to install all applications or choose
user_choice=$(zenity --list \
    --title="Installation Option" \
    --text="Do you want to install all applications or choose specific ones?" \
    --radiolist \
    --column="Select" \
    --column="Install Option" \
    FALSE "All Apps" \
    TRUE "Specific Apps" \
    --width=600 \
    --height=400 \
)
echo -e ""

# Check if the user pressed Cancel or closed the dialog
if [ $? -eq 1 ]; then
    echo -e "${RED}Operation cancelled.${NC}"
    exit 1
fi

if [ "$user_choice" == "Install All" ]; then
    # Install all applications
    for app in "${apps_to_install[@]}"; do
        check_and_install "$(echo $app | cut -d ':' -f 1)"
    done
else
    # Use zenity to select applications
    apps_selected=$(zenity --list \
        --title="Select Applications to Install" \
        --checklist \
        --column="Install" \
        --column="Application" \
        --column="Description" \
        "${zenity_options[@]}" \
        --separator=" " \
        --width=800 \
        --height=600 \
    )
    # Check if the user pressed Cancel or closed the dialog
    if [ $? -eq 1 ]; then
        echo -e "${RED}Operation cancelled.${NC}"
        exit 1
    fi
    # Install selected applications
    for app in $apps_selected; do
        if [[ "$app" == "code:"* ]]; then
            ./scripts/install_vscode.sh
        else
            check_and_install "$app"
        fi
    done
fi

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

echo -e "\n${GREEN}Script completed.${NC}"

