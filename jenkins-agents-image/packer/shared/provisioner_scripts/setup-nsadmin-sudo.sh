#!/bin/bash
color="\033[1;35m" # magenta
reset="\033[0m" # reset
echo -e "${color}Adding nsadmin user to /etc/sudoers${reset}"
sudo bash -c 'echo "nsadmin ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers'