#!/bin/bash
color="\033[1;35m" # magenta
reset="\033[0m" # reset
echo -e "${color}Adding nsadmin user${reset}"

echo -e "${color}in nsadmin user script${reset}"


sudo /usr/sbin/useradd \
        --create-home \
        --shell /bin/bash \
        nsadmin

sudo /usr/sbin/usermod -aG sudo nsadmin
sudo /usr/sbin/usermod -aG docker nsadmin
sudo mkdir -p /opt/ns/log && sudo chown -R nsadmin:nsadmin /opt/ns

# Add nsadmin to sudoers
echo "nsadmin ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/nsadmin
sudo chmod 0440 /etc/sudoers.d/nsadmin