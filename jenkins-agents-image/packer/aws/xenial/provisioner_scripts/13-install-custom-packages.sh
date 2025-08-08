#!/bin/bash
color="\033[1;35m" # magenta
reset="\033[0m"
echo -e "${color}Installing custom packages${reset}"

# Install custom packages

cd /opt
sudo curl -L "https://github.com/docker/compose/releases/download/1.26.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

sudo curl "https://s3.amazonaws.com/aws-cli/awscli-bundle-1.19.39.zip" -o "awscli-bundle.zip"
sudo unzip awscli-bundle.zip
sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
sudo rm awscli-bundle.zip