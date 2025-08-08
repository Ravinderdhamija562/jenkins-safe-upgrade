#!/bin/bash

color="\033[1;35m" # magenta
reset="\033[0m"
echo -e "${color}Configuring apt repos${reset}"
# Add Docker repository
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/download_docker_com_linux_ubuntu.list

# Add NodeSource repository (Node.js 8.x)
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | sudo apt-key add -
echo "deb https://deb.nodesource.com/node_8.x $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/nodesource.list

# Add Ubuntu Toolchain Test repository
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys BA9EF27F
sudo add-apt-repository "deb http://ppa.launchpad.net/ubuntu-toolchain-r/test/ubuntu $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/ubuntu-toolchain-r-ubuntu-test-xenial.list

# Update package list
sudo apt-get update