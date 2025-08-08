#!/bin/bash
color="\033[1;35m" # magenta
reset="\033[0m"
echo -e "${color}Installing OpenJDK 17${reset}"
cd /opt
sudo wget https://download.java.net/java/GA/jdk17/0d483333a00540d886896bac774ff48b/35/GPL/openjdk-17_linux-x64_bin.tar.gz
sudo tar -xvf openjdk-17*
sudo mkdir -p /usr/lib/jvm
sudo mv jdk-17 /usr/lib/jvm/.

sudo rm -f openjdk-17_linux-x64_bin.tar.gz

# Add JDK to PATH in /etc/environment
sudo sed -i 's|^PATH="\(.*\)"|PATH="/usr/lib/jvm/jdk-17/bin:\1"|' /etc/environment
echo 'JAVA_HOME=/usr/lib/jvm/jdk-17' | sudo tee -a /etc/environment

# Reload the environment to apply changes
source /etc/environment