#!/bin/bash

color="\033[1;35m" # magenta
reset="\033[0m"
echo -e "${color}Partioning the disk${reset}"

# Step 1: Fix the GPT table to use the entire disk
sudo sgdisk -e /dev/sda

# Step 2: Resize partition 3 to use the full disk
sudo parted --script /dev/sda resizepart 3 100%

# Step 3: Resize the physical volume to reflect the new partition size
sudo pvresize /dev/sda3

#Step 4: Extend the logical volume to use all free space
sudo lvextend -l +100%FREE /dev/mapper/U16--vg-root

# Step 5: Resize the filesystem to use the expanded logical volume
sudo resize2fs /dev/mapper/U16--vg-root