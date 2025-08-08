#!/bin/bash
color="\033[1;35m" # magenta
reset="\033[0m"
echo -e "${color}Installing JFrog CLI${reset}"

jfrog_cli_version="2.49.1"
curl -f --connect-timeout 10 --max-time 30 --retry 20 --retry-delay 30 --retry-max-time 900 https://artifactory-rd.company.io/artifactory/ep-tools/jfrog-cli/v2-jf/${jfrog_cli_version}/scripts/install-cli.sh | sudo bash -s -- ${jfrog_cli_version}
sudo chmod +x /usr/local/bin/jf
sudo chown -f nsadmin:nsadmin /usr/local/bin/jf
sudo chown -f nsadmin:nsadmin /home/nsadmin/.jfrog || :