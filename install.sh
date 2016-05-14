#!/bin/bash

# Shell color variables
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
blue=`tput setaf 4`
lightgrey=`tput setaf 6`
reset=`tput sgr0`

sudo mkdir -p /var/www/html

cd /var/www/html

# Resolved rights problems
sudo groupadd fredi
sudo usermod -a -G fredi www-data
sudo usermod -a -G fredi $(whoami)
sudo chown -R $(whoami):fredi /var/www/html
sudo chgrp -R fredi /var/www/html

projectFolder=/var/www/html/pleaky

printf "${green}We are now going to clone the project${reset}\n"
git clone git@github.com:iknsa/fredi.git $projectFolder

# Create public folders with appropriate chmod

# Go to the project directory
cd $projectFolder

directories=(web/docs web/uploads var/cache var/logs var/sessions install/)
for directory in ${directories[*]}
do
  mkdir -p $directory/

  # Set full rights to these directories
  sudo chmod -R 777 $directory/
done

# Make sure kernel is up to date before getting started
sudo apt-get update --fix-missing
sudo apt-get upgrade

# Install lamp-server PHP Apache MySQL
printf "${yellow}Looks like php is not installed. We'll install the whole lamp-server stack with tasksel${reset}\n"
sudo apt-get install tasksel
sudo tasksel install lamp-server

printf "${green}We are now going to install a few stuffs for php${reset}\n"
# Install Curl and php5-curl (php5-curl gets enabled automatically)
# Install php5-cgi to launch install/index.php with params
sudo apt-get install php5-curl curl

printf "${yellow}We are now going to install phpmyadmin${reset}\n"
# Installing phpmyadmin as it is useful for devs
sudo apt-get install phpmyadmin

# Composer bug lack of memory
# https://getcomposer.org/doc/articles/troubleshooting.md#proc-open-fork-failed-errors
sudo /bin/dd if=/dev/zero of=/var/swap.1 bs=1M count=1024
sudo /sbin/mkswap /var/swap.1
sudo /sbin/swapon /var/swap.1

# Composer installation
printf "${yellow}Composer is not installed globally... We'll try to get it done :)${reset}\n"
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

# Install composer dependencies
if [ -x "$(command -v composer)" ]; then
    printf "${green}Yeah!!! Composer installed properly.\n${yellow}We are now going to install the vendors${reset}\n"
    composer install

    printf "${green}Seems everything went ok${reset}\n"
fi

# Setup application's database
php bin/console doctrine:database:create
php bin/console doctrine:schema:update --force
php bin/console doctrine:fixtures:load --append

# npm install bug
# This is a temporary fix as it will be fixed in npm#2.7
mkdir -p /home/$(whoami)/tmp
sudo chmod -R 777 /home/$(whoami)/tmp
# @todo to remove this hack as it may present a security issue

# Npm installation
printf "${yellow}Looks like npm are not installed... We'll give it a shot.${reset}\n"
sudo apt-get install npm 

# Bower install
printf "${yellow}We are now going to install bower globally${reset}\n"

# Install bower if was not installed
sudo npm install -g bower
# Symbolic link for bower as sometimes bugs
sudo ln -s /usr/bin/nodejs /usr/bin/node

# Install dependencies
# Checks that bower installed properly
if ! [ -x "$(command -v bower)" ]; then
    printf "${red}Ooops... Bower did not installed properly${reset}\n"
else
    printf "${yellow}Installing bower dependencies${reset}\n"
    bower install
fi

if [ -x "$(command -v composer)" ]; then
    printf "${green}Yeah!!! Composer installed properly. ${yellow}We are now going to install the vendors${reset}\n"

    composer install

    printf "${green}Seems everything went ok${reset}\n"
else
    printf "${red}Vendors did not install properly. Please install it manually with the comand composer install${reset}\n"
fi

for directory in ${directories[*]}
do
  mkdir -p $directory/

  # Set full rights to these directories
  sudo chmod -R 777 $directory/
done