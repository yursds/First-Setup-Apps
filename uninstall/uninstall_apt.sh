#!/bin/bash

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# File path
LIST='./list/apt_apps.txt'

# Function to check if a package is installed and uninstall it
check_and_uninstall() {
    if dpkg -l | grep -q "$1"; then
        echo -e "${RED}Removing $1...${NC}"
        sudo apt remove -y "$1"
        if [ $? -eq 0 ]; then
            echo -e "${RED}$1 removal successful.${NC}"
            removed_apps+=("$1")
        else
            echo -e "${RED}Error removing $1.${NC}"
            not_removed_apps+=("$1")
        fi
    else
        echo -e "${GREEN}$1 is not installed.${NC}"
        not_removed_apps+=("$1")
    fi
}

# Arrays to hold the status of applications
removed_apps=()
not_removed_apps=()

# Read applications from the text file, skip empty lines and lines starting with '#' 
mapfile -t apps_to_uninstall < <(grep -vE '^(#|$)' ${LIST})

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

# Ask if the user wants to uninstall all applications or choose
user_choice=$(zenity --list \
    --title="Uninstallation Option" \
    --text="Do you want to uninstall all applications or choose specific ones?" \
    --radiolist \
    --column="Select" --column="Option" \
    TRUE "Uninstall All" \
    FALSE "Choose Specific Apps" \
    --width=600 \
    --height=400 \
)
echo -e ""

# Check if the user pressed Cancel or closed the dialog
if [ $? -eq 1 ]; then
    echo -e "${RED}Operation cancelled.${NC}"
    exit 1
fi

if [ "$user_choice" == "Uninstall All" ]; then
    # Uninstall all applications
    for app in "${apps_to_uninstall[@]}"; do
        check_and_uninstall "$(echo $app | cut -d ':' -f 1)"
    done
else
    # Use zenity to select applications
    apps_selected=$(zenity --list \
        --title="Select Applications to Uninstall" \
        --checklist \
        --column="Uninstall" \
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
    # Uninstall selected applications
    for app in $apps_selected; do
        check_and_uninstall "$app"
    done
fi

# Summary of removed and not removed applications
if [ ${#removed_apps[@]} -ne 0 ]; then
    echo -e "\n${RED}Removed applications:${NC}"
    for app in "${removed_apps[@]}"; do
        echo -e "${RED}- $app${NC}"
    done
fi

if [ ${#not_removed_apps[@]} -ne 0 ]; then
    echo -e "\n${GREEN}Not removed applications:${NC}"
    for app in "${not_removed_apps[@]}"; do
        echo -e "${GREEN}- $app${NC}"
    done
fi

echo -e "\nDone!\n"

