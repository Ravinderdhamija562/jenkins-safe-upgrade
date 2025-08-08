#!/bin/bash
color="\033[1;35m" # magenta
reset="\033[0m"
echo -e "${color}Configuring nsadmin as sudo user${reset}"
sudo bash -c 'echo "nsadmin ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers'