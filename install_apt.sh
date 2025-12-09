#!/bin/bash

# Define color codes
RED='\033[0;31m'
YELLOW='\033[33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# File path
LIST='./apt_apps.txt'

# Default to Interactive Mode (GUI enabled)
INTERACTIVE=true

# Check for arguments to enable headless/auto mode (for CI/CD or scripts)
for arg in "$@"; do
    if [ "$arg" == "--auto" ] || [ "$arg" == "--ci" ]; then
        INTERACTIVE=false
        echo -e "${YELLOW}Running in AUTOMATED mode (No GUI). Installing all apps.${NC}"
    fi
done

# Arrays to hold the status of applications
installed_apps=()
already_installed_apps=()
not_installed_apps=()

# Function to check if a package is installed and install it if not
check_and_install() {
    if dpkg -s "$1" &> /dev/null; then
        echo -e "${YELLOW}$1 is already installed.${NC}"
        already_installed_apps+=("$1")
    else
        echo -e "${GREEN}Installing $1...${NC}"
        # DEBIAN_FRONTEND=noninteractive prevents apt from popping up dialogs during auto-install
        sudo DEBIAN_FRONTEND=noninteractive apt install -y "$1"
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}$1 installation successful.${NC}"
            installed_apps+=("$1")
        else
            echo -e "${RED}Error installing $1.${NC}"
            not_installed_apps+=("$1")
        fi
    fi
}

# Check if the list file exists
if [ ! -f "$LIST" ]; then
    echo -e "${RED}File $LIST not found!${NC}"
    exit 1
fi

# Read applications from the text file, skip empty lines and lines starting with '#'
mapfile -t apps_to_install < <(grep -vE '^(#|$)' ${LIST})


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
        # Check for category lines (starting with #)
        if [[ $line =~ ^# ]]; then
            current_category=$(echo $line | sed 's/^# //')
        else
            # Extract name and description
            name=$(echo $line | cut -d ':' -f 1)
            description=$(echo $line | cut -d ':' -f 2)
            if [[ -z "$description" ]]; then
                description="No description available"
            fi
            zenity_options+=("FALSE" "$name" "$current_category: $description")
        fi
    done < ${LIST}

    # Ask if the user wants to install all applications or choose specific ones
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
else
    # AUTOMATED MODE: Default to "All Apps" without asking
    user_choice="All Apps"
fi


# --- INSTALLATION LOGIC ---

if [ "$user_choice" == "All Apps" ]; then
    # Install all applications
    echo -e "Starting installation of ALL applications..."
    for app in "${apps_to_install[@]}"; do
        # Clean the app name (remove description if present)
        app_name=$(echo $app | cut -d ':' -f 1)
        check_and_install "$app_name"
    done
else
    # Use zenity to select applications (Only in Interactive Mode)
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
        check_and_install "$app"
    done
fi

# --- SUMMARY SECTION ---

# Summary of newly installed applications
if [ ${#installed_apps[@]} -ne 0 ]; then
    echo -e "\nInstalled applications:"
    for app in "${installed_apps[@]}"; do
        echo -e "- $app"
    done
fi

# Summary of applications that were already installed
if [ ${#already_installed_apps[@]} -ne 0 ]; then
    echo -e "\n${YELLOW}Already installed applications:"
    for app in "${already_installed_apps[@]}"; do
        echo -e "- $app"
    done
fi

# Summary of applications that failed to install
if [ ${#not_installed_apps[@]} -ne 0 ]; then
    echo -e "\n${RED}Not installed applications:${NC}"
    for app in "${not_installed_apps[@]}"; do
        echo -e "${RED}- $app${NC}"
    done
fi

echo -e "\n${GREEN}Script completed.${NC}"