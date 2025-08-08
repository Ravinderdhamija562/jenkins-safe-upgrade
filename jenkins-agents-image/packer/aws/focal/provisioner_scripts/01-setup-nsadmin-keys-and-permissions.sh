#!/bin/bash
color="\033[1;35m" # magenta
reset="\033[0m"
echo -e "${color}Setup nsadmin keys and permissions${reset}"
sudo mkdir -p /home/nsadmin/.ssh
# Append the public key to authorized_keys
sudo bash -c 'cat /tmp/resources/nsadmin_public_key >> /home/nsadmin/.ssh/authorized_keys'

sudo chown -R nsadmin:nsadmin /home/nsadmin/.ssh
sudo chmod 600 /home/nsadmin/.ssh/authorized_keys
sudo chmod 1777 /tmp
sudo mkdir -p /opt/ns/log
sudo chown nsadmin:nsadmin /opt/ns
sudo chown nsadmin:nsadmin /home/nsadmin/.gitconfig