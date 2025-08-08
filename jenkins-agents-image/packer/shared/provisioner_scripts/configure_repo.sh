#!/bin/bash

# Detect Ubuntu version (Xenial, Bionic, or Focal)
if [[ $(lsb_release -c | grep -oP '(?<=Codename:\s)\w+') == "xenial" ]]; then
    UBUNTU_VERSION="xenial"
elif [[ $(lsb_release -c | grep -oP '(?<=Codename:\s)\w+') == "bionic" ]]; then
    UBUNTU_VERSION="bionic"
elif [[ $(lsb_release -c | grep -oP '(?<=Codename:\s)\w+') == "focal" ]]; then
    UBUNTU_VERSION="focal"
else
    echo "Unsupported Ubuntu version."
    exit 1
fi

if [[ "$UBUNTU_VERSION" == "xenial" ]]; then
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/download_docker_com_linux_ubuntu.list

    # Add NodeSource repository (Node.js 8.x)
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | sudo apt-key add -
    echo "deb https://deb.nodesource.com/node_8.x $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/nodesource.list

    # Add Ubuntu Toolchain Test repository
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys BA9EF27F
    sudo add-apt-repository "deb http://ppa.launchpad.net/ubuntu-toolchain-r/test/ubuntu $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/ubuntu-toolchain-r-ubuntu-test-xenial.list
fi

# Backup the current sources list
echo "Backing up sources.list"
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak

# Add the company Artifactory repository based on the detected Ubuntu version
echo "Updating sources.list for $UBUNTU_VERSION"
echo "deb https://artifactory-rd.company.io/artifactory/ubuntu/ $UBUNTU_VERSION main restricted" | sudo tee  /etc/apt/sources.list
echo "deb https://artifactory-rd.company.io/artifactory/ubuntu/ $UBUNTU_VERSION-updates main restricted" | sudo tee -a /etc/apt/sources.list
echo "deb https://artifactory-rd.company.io/artifactory/ubuntu/ $UBUNTU_VERSION universe" | sudo tee -a /etc/apt/sources.list
echo "deb https://artifactory-rd.company.io/artifactory/ubuntu/ $UBUNTU_VERSION-updates universe" | sudo tee -a /etc/apt/sources.list
echo "deb https://artifactory-rd.company.io/artifactory/ubuntu/ $UBUNTU_VERSION multiverse" | sudo tee -a /etc/apt/sources.list
echo "deb https://artifactory-rd.company.io/artifactory/ubuntu/ $UBUNTU_VERSION-updates multiverse" | sudo tee -a /etc/apt/sources.list
echo "deb https://artifactory-rd.company.io/artifactory/ubuntu/ $UBUNTU_VERSION-backports main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list

# Update the package list
echo "Updating package list from company Artifactory repository"
sudo apt-get update -y