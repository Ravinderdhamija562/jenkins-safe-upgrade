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

echo '[global]' | sudo tee -a /etc/pip.conf
echo 'index-url = https://artifactory-rd.company.io/artifactory/api/pypi/company-py38/simple' | sudo tee -a /etc/pip.conf
echo 'timeout = 180' | sudo tee -a /etc/pip.conf


sudo -H python3.5 -m pip install --upgrade pip==20.2.4
sudo -H python3.5 -m pip install --upgrade setuptools==44.0.0
echo "setuptools and pip version with python3.5 are below:"
sudo -H python3.5 -m pip show setuptools
sudo -H python3.5 -m pip show pip
#cloud-init --version #21.1-19-gbad84ad4-0ubuntu1~16.04.4

#sleep 10000
#curl -O https://bootstrap.pypa.io/pip/3.8/get-pip.py
wget https://artifactory-rd.company.io/artifactory/company-generic/python/pip/3.8/get-pip.py
sudo -H PIP_INDEX_URL=https://artifactory-rd.company.io/artifactory/api/pypi/company-py38/simple python3.8 get-pip.py --no-setuptools --no-wheel
sudo -H python3.8 -m pip show pip
sudo -H python3.8 -m pip install --upgrade setuptools==44.0.0
sudo -H python3.8 -m pip show setuptools

# sudo rm -rf /usr/local/lib/python3.8/dist-packages/setuptools*
# sudo rm -rf /usr/local/lib/python3.8/dist-packages/pip*
# sudo rm -f /usr/local/bin/pip3.8

#sudo python3.8 -m pip install --upgrade pip==20.2.3

#sudo -H pip3 install --upgrade pip==22.0.4

# removing existing docutils package, as pip can't install it again as it complains that it is managed by distutils so can't uninstall it completely
sudo rm -rf /usr/lib/python3/dist-packages/docutils*

if [ -f /tmp/requirements.txt ]; then
  grep -v '^#' /tmp/requirements.txt > /tmp/filtered_requirements.txt
  sudo -H python3.8 -m pip install -r /tmp/filtered_requirements.txt
  rm -f /tmp/filtered_requirements.txt
else
  echo "Error: /tmp/requirements.txt not found."
  exit 1
fi

echo "installed pip packages are below:"
pip3 list