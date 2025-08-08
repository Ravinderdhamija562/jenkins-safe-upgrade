#!/bin/bash
color="\033[1;35m" # magenta
reset="\033[0m"
echo -e "${color}Setting up python and pip${reset}"

#sudo -H pip config set --global global.index-url 'https://artifactory-rd.company.io/artifactory/api/pypi/company-py38/simple'
#sudo -H pip config set --global global.timeout 180
#sudo -H pip install --upgrade pip==22.0.4

# Add company repository
curl -fsSL https://artifactory.company.io/artifactory/api/gpg/key/public | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://artifactory.company.io/artifactory/external xenial main"
sudo apt-get update

sudo apt install -y python3.8 python3.8-dev python3.8-venv

sudo python3.8 -m ensurepip --upgrade
sudo ln -s /usr/local/bin/pip3 /usr/bin/pip3

echo '[global]' | sudo tee -a /etc/pip.conf
echo 'index-url = https://artifactory-rd.company.io/artifactory/api/pypi/company-py38/simple' | sudo tee -a /etc/pip.conf
echo 'timeout = 180' | sudo tee -a /etc/pip.conf
sudo -H pip3 install --upgrade pip==22.0.4

#sudo ln -s /usr/local/bin/pip3 /usr/bin/pip3
#sudo ln -s /usr/local/bin/pip3 /usr/bin/pip
cat /tmp/requirements.txt
sudo python3.8 -m pip install -r /tmp/requirements.txt