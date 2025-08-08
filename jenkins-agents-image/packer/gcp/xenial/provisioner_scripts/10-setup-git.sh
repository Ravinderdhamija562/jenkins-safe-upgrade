#!/bin/bash
color="\033[1;35m" # magenta
reset="\033[0m"
echo -e "${color}Configuring git for all users${reset}"

sudo mkdir -p /usr/etc
sudo git config --system url."https://github.com/".insteadof "git@github.com:"
