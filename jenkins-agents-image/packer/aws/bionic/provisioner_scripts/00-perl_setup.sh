#!/bin/bash
color="\033[1;35m" # magenta
reset="\033[0m" # reset
echo -e "${color}Setup Perl${reset}"

sudo PERL_MM_USE_DEFAULT=1  perl -MCPAN -e 'install Bundle::CPAN'
sudo PERL_MM_USE_DEFAULT=1  perl -MCPAN -e 'install XML::SAX'
sudo PERL_MM_USE_DEFAULT=1  perl -MCPAN -e 'install XML::LibXML'
sudo cpan install JSON
sudo apt-get purge -y --auto-remove unattended-upgrades
sudo apt-get -y autoremove && sudo apt-get -y autoclean && sudo apt-get -y clean