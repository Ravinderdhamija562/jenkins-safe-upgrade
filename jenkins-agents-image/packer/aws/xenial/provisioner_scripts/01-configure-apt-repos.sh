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

# sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
# sudo bash -c 'cat <<EOL > /etc/apt/sources.list
# deb https://artifactory-rd.company.io/artifactory/ubuntu/ xenial main restricted
# deb https://artifactory-rd.company.io/artifactory/ubuntu/ xenial-updates main restricted
# deb https://artifactory-rd.company.io/artifactory/ubuntu/ xenial universe
# deb https://artifactory-rd.company.io/artifactory/ubuntu/ xenial-updates universe
# deb https://artifactory-rd.company.io/artifactory/ubuntu/ xenial multiverse
# deb https://artifactory-rd.company.io/artifactory/ubuntu/ xenial-updates multiverse
# deb https://artifactory-rd.company.io/artifactory/ubuntu/ xenial-backports main restricted universe multiverse
# EOL'  

# Update package list
sudo apt-get update