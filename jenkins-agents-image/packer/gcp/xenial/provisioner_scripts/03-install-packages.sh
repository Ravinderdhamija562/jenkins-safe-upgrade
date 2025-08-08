#!/bin/bash
color="\033[1;35m" # magenta
reset="\033[0m"
echo -e "${color}Installing packages${reset}"

# Install packages
export DEBIAN_FRONTEND=noninteractive
# these dpkg options are to avoid interactive prompts during installation
#echo 'grub-efi-amd64 grub-efi-amd64/keep_default_grub boolean true' | debconf-set-selections
sudo DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install -y $(grep -v '^#' /tmp/packages.txt)
#sudo DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install -y grub-efi-amd64