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

# Check for arguments
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
    # FIX: Ensure clean variable name
    pkg_name=$(echo "$1" | xargs)
    
    if dpkg -s "$pkg_name" &> /dev/null; then
        echo -e "${YELLOW}$pkg_name is already installed.${NC}"
        already_installed_apps+=("$pkg_name")
    else
        echo -e "${GREEN}Installing $pkg_name...${NC}"
        if sudo DEBIAN_FRONTEND=noninteractive apt install -y "$pkg_name"; then
            echo -e "${GREEN}$pkg_name installation successful.${NC}"
            installed_apps+=("$pkg_name")
        else
            echo -e "${RED}Error installing $pkg_name.${NC}"
            not_installed_apps+=("$pkg_name")
        fi
    fi
}

# Check if file exists
if [ ! -f "$LIST" ]; then
    echo -e "${RED}File $LIST not found!${NC}"
    exit 1
fi

# Read applications
mapfile -t apps_to_install < <(grep -vE '^(#|$)' "${LIST}")

# --- USER SELECTION LOGIC ---

if [ "$INTERACTIVE" = true ]; then
    zenity_options=()
    current_category=""
    while IFS= read -r line; do
        if [[ -z "$line" ]]; then continue; fi
        
        if [[ $line =~ ^# ]]; then
            current_category=${line#\# }
        else
            # FIX: trim whitespace using xargs
            name=$(echo "$line" | cut -d ':' -f 1 | xargs)
            description=$(echo "$line" | cut -d ':' -f 2 | xargs)
            if [[ -z "$description" ]]; then description="No description available"; fi
            zenity_options+=("FALSE" "$name" "$current_category: $description")
        fi
    done < "${LIST}"

    user_choice=$(zenity --list \
        --title="Installation Option" \
        --text="Do you want to install all applications or choose specific ones?" \
        --radiolist \
        --column="Select" \
        --column="Install Option" \
        FALSE "All Apps" \
        TRUE "Specific Apps" \
        --width=600 --height=400 )
    
    exit_code=$?
    echo -e ""

    if [ $exit_code -eq 1 ]; then
        echo -e "${RED}Operation cancelled.${NC}"
        exit 1
    fi
else
    user_choice="All Apps"
fi

# --- INSTALLATION LOGIC ---

if [ "$user_choice" == "All Apps" ]; then
    echo -e "Starting installation of ALL applications..."
    for app in "${apps_to_install[@]}"; do
        # FIX: Added | xargs to trim whitespace
        app_name=$(echo "$app" | cut -d ':' -f 1 | xargs)
        check_and_install "$app_name"
    done
else
    apps_selected=$(zenity --list \
        --title="Select Applications to Install" \
        --checklist \
        --column="Install" \
        --column="Application" \
        --column="Description" \
        "${zenity_options[@]}" \
        --separator=" " \
        --width=800 --height=600 )
    
    exit_code=$?
    
    if [ $exit_code -eq 1 ]; then
        echo -e "${RED}Operation cancelled.${NC}"
        exit 1
    fi
    
    # shellcheck disable=SC2086 
    for app in $apps_selected; do
        # FIX: Ensure trimmed
        clean_app=$(echo "$app" | xargs)
        check_and_install "$clean_app"
    done
fi

# --- SUMMARY ---

if [ ${#installed_apps[@]} -ne 0 ]; then
    echo -e "\nInstalled applications:"
    for app in "${installed_apps[@]}"; do echo -e "- $app"; done
fi

if [ ${#already_installed_apps[@]} -ne 0 ]; then
    echo -e "\n${YELLOW}Already installed applications:"
    for app in "${already_installed_apps[@]}"; do echo -e "- $app"; done
fi

if [ ${#not_installed_apps[@]} -ne 0 ]; then
    echo -e "\n${RED}Not installed applications:${NC}"
    for app in "${not_installed_apps[@]}"; do echo -e "${RED}- $app${NC}"; done
fi

echo -e "\n${GREEN}Script completed.${NC}"