#!/bin/bash
color="\033[1;35m" # magenta
reset="\033[0m" # reset
echo -e "${color}Setting up conda${reset}"

conda_version="24.11.0-0"
cd /opt
sudo curl -O -L https://github.com/conda-forge/miniforge/releases/download/${conda_version}/Miniforge3-Linux-x86_64.sh
sudo bash ./Miniforge3-Linux-x86_64.sh -b -p ./miniforge
sudo ln -s /opt/miniforge/bin/conda /usr/bin/conda
conda -V
sudo rm Miniforge3-Linux-x86_64.sh