#!/bin/bash
color="\033[1;35m" # magenta
reset="\033[0m"
echo -e "${color}update git version${reset}"

GIT_VERSION=2.28.0
wget https://www.kernel.org/pub/software/scm/git/git-$GIT_VERSION.tar.gz
tar -zxf git-$GIT_VERSION.tar.gz
cd git-$GIT_VERSION
make configure
./configure --prefix=/usr
make all doc info
sudo make install install-doc install-html install-info
echo "Git version:"
git --version

echo -e "${color}Configuring git for all users${reset}"
sudo mkdir -p /usr/etc
sudo git config --system url."https://github.com/".insteadof "git@github.com:" 