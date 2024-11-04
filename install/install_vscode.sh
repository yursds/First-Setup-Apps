#!/bin/bash

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Install dependencies
echo -e "${GREEN}Installing wget and gpg...${NC}"
sudo apt-get install wget gpg

# Add Microsoft GPG key
echo -e "${GREEN}Adding Microsoft GPG key...${NC}"
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
rm -f packages.microsoft.gpg

# Add VS Code repository
echo -e "${GREEN}Adding VS Code repository...${NC}"
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null

# Update package cache and install VS Code
echo -e "${GREEN}Installing apt-transport-https...${NC}"
sudo apt install apt-transport-https
echo -e "${GREEN}Updating package cache...${NC}"
sudo apt update
echo -e "${GREEN}Installing VS Code...${NC}"
sudo apt install code # or code-insiders

echo -e "${GREEN}VS Code installation completed.${NC}"

