#!/bin/bash
color="\033[1;35m" # magenta
reset="\033[0m" # reset
echo -e "${color}Adding nsadmin user${reset}"
# Create user
sudo /usr/sbin/useradd \
  --create-home \
  --shell /bin/bash \
  nsadmin
# Add to groups
sudo /usr/sbin/usermod -aG sudo nsadmin

# Skip Docker group for Bionic
UBUNTU_VERSION=$(lsb_release -sc)
if [[ "$UBUNTU_VERSION" != "bionic" ]]; then
  sudo /usr/sbin/usermod -aG docker nsadmin
fi

# Create log directory and set permissions
sudo mkdir -p /opt/ns/log && sudo chown -R nsadmin:nsadmin /opt/ns