#!/bin/bash

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[33m'
NC='\033[0m' # No Color

# File path
LIST='./apt_apps.txt'

# Default to Interactive Mode
INTERACTIVE=true

# Check for arguments
for arg in "$@"; do
    if [ "$arg" == "--auto" ] || [ "$arg" == "--ci" ]; then
        INTERACTIVE=false
        echo -e "${YELLOW}Running in AUTOMATED mode (No GUI). Uninstalling all apps.${NC}"
    fi
done

# Function to check if a package is installed and uninstall it
check_and_uninstall() {
    # FIX: Clean variable name
    pkg_name=$(echo "$1" | xargs)
    
    if dpkg -s "$pkg_name" &> /dev/null; then
        echo -e "${RED}Removing $pkg_name...${NC}"
        if sudo DEBIAN_FRONTEND=noninteractive apt remove -y "$pkg_name"; then
            echo -e "${RED}$pkg_name removal successful.${NC}"
            removed_apps+=("$pkg_name")
        else
            echo -e "${RED}Error removing $pkg_name.${NC}"
            not_removed_apps+=("$pkg_name")
        fi
    else
        echo -e "${GREEN}$pkg_name is not installed (skipping).${NC}"
    fi
}

# Arrays to hold the status of applications
removed_apps=()
not_removed_apps=()

# Check if file exists
if [ ! -f "$LIST" ]; then
    echo -e "${RED}File $LIST not found!${NC}"
    exit 1
fi

# Read applications
mapfile -t apps_to_uninstall < <(grep -vE '^(#|$)' "${LIST}")

# --- USER SELECTION LOGIC ---

if [ "$INTERACTIVE" = true ]; then
    zenity_options=()
    current_category=""
    while IFS= read -r line; do
        if [[ -z "$line" ]]; then continue; fi
        
        if [[ $line =~ ^# ]]; then
            current_category=${line#\# }
        else
            # FIX: Trim whitespace
            name=$(echo "$line" | cut -d ':' -f 1 | xargs)
            description=$(echo "$line" | cut -d ':' -f 2 | xargs)
            if [[ -z "$description" ]]; then description="No description available"; fi
            zenity_options+=("FALSE" "$name" "$current_category: $description")
        fi
    done < "${LIST}"

    user_choice=$(zenity --list \
        --title="Uninstallation Option" \
        --text="Do you want to uninstall all applications or choose specific ones?" \
        --radiolist \
        --column="Select" --column="Uninstall Option" \
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

# --- UNINSTALLATION LOGIC ---

if [ "$user_choice" == "All Apps" ]; then
    for app in "${apps_to_uninstall[@]}"; do
        # FIX: Trim whitespace
        app_name=$(echo "$app" | cut -d ':' -f 1 | xargs)
        check_and_uninstall "$app_name"
    done
else
    apps_selected=$(zenity --list \
        --title="Select Applications to Uninstall" \
        --checklist \
        --column="Uninstall" \
        --column="Application" \
        --column="Description" \
        "${zenity_options[@]}" \
        --separator=" " \
        --width=600 --height=400 )
    
    exit_code=$?

    if [ $exit_code -eq 1 ]; then
        echo -e "${RED}Operation cancelled.${NC}"
        exit 1
    fi
    
    # shellcheck disable=SC2086
    for app in $apps_selected; do
        clean_app=$(echo "$app" | xargs)
        check_and_uninstall "$clean_app"
    done
fi

# --- SUMMARY ---

if [ ${#removed_apps[@]} -ne 0 ]; then
    echo -e "\n${RED}Removed applications:${NC}"
    for app in "${removed_apps[@]}"; do echo -e "${RED}- $app${NC}"; done
fi

if [ ${#not_removed_apps[@]} -ne 0 ]; then
    echo -e "\n${YELLOW}Issues removing:${NC}"
    for app in "${not_removed_apps[@]}"; do echo -e "${YELLOW}- $app${NC}"; done
fi

echo -e "\n${GREEN}Done!\n${NC}"