#!/bin/bash

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[33m'
NC='\033[0m' # No Color

# File path
LIST='./apt_apps.txt'

# Default to Interactive Mode (GUI enabled)
INTERACTIVE=true

# Check for arguments (flags) to enable headless/auto mode
for arg in "$@"; do
    if [ "$arg" == "--auto" ] || [ "$arg" == "--ci" ]; then
        INTERACTIVE=false
        echo -e "${YELLOW}Running in AUTOMATED mode (No GUI). Uninstalling all apps.${NC}"
    fi
done

# Function to check if a package is installed and uninstall it
check_and_uninstall() {
    # FIX: Use 'dpkg -s' instead of 'which' to verify if the package is truly installed
    if dpkg -s "$1" &> /dev/null; then
        echo -e "${RED}Removing $1...${NC}"
        # DEBIAN_FRONTEND=noninteractive prevents apt from popping up dialogs
        sudo DEBIAN_FRONTEND=noninteractive apt remove -y "$1"
        
        if [ $? -eq 0 ]; then
            echo -e "${RED}$1 removal successful.${NC}"
            removed_apps+=("$1")
        else
            echo -e "${RED}Error removing $1.${NC}"
            not_removed_apps+=("$1")
        fi
    else
        echo -e "${GREEN}$1 is not installed (skipping).${NC}"
        # We don't add it to 'not_removed_apps' as error, because it wasn't there to begin with
    fi
}

# Arrays to hold the status of applications
removed_apps=()
not_removed_apps=()

# Check if the list file exists
if [ ! -f "$LIST" ]; then
    echo -e "${RED}File $LIST not found!${NC}"
    exit 1
fi

# Read applications from the text file, skip empty lines and lines starting with '#' 
mapfile -t apps_to_uninstall < <(grep -vE '^(#|$)' ${LIST})


# --- USER SELECTION LOGIC ---

if [ "$INTERACTIVE" = true ]; then
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
        --column="Select" --column="Uninstall Option" \
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
else
    # AUTOMATED MODE: Default to "All Apps"
    user_choice="All Apps"
fi


# --- UNINSTALLATION LOGIC ---

if [ "$user_choice" == "All Apps" ]; then
    # Uninstall all applications found in the list
    echo -e "Starting uninstallation of ALL listed applications..."
    for app in "${apps_to_uninstall[@]}"; do
        app_name=$(echo $app | cut -d ':' -f 1)
        check_and_uninstall "$app_name"
    done
else
    # Use zenity to select applications (Only in Interactive Mode)
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


# --- SUMMARY ---

# Summary of removed applications
if [ ${#removed_apps[@]} -ne 0 ]; then
    echo -e "\n${RED}Removed applications:${NC}"
    for app in "${removed_apps[@]}"; do
        echo -e "${RED}- $app${NC}"
    done
fi

# Summary of applications that failed to remove
if [ ${#not_removed_apps[@]} -ne 0 ]; then
    echo -e "\n${YELLOW}Issues removing:${NC}"
    for app in "${not_removed_apps[@]}"; do
        echo -e "${YELLOW}- $app${NC}"
    done
fi

# Optional: Run autoremove to clean up unused dependencies
# echo -e "\nCleaning up unused dependencies..."
# sudo apt autoremove -y

echo -e "\n${GREEN}Done!\n${NC}"