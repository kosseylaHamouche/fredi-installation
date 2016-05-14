# fredi-installation

start by installing git and set up your ssh connection.

The official documentation is available on github: https://help.github.com/articles/checking-for-existing-ssh-keys/#platform-linux

The steps to follow is available here: https://drive.google.com/open?id=0B9HVbv29cDuvRXQ0M1dIckRpSXM

Clone the repository

git clone git@github.com:kosseylaHamouche/fredi-installation.git

Go into the newly cloned repository

cd fredi-installation

Then launch the install bash file

./install.sh

during the installation process set a password equal to 'root' for MySQL

This installation process is for first time installation on fresh ubuntu.

For easy purpose set all passwords to root. You will be able to change your password later for production.

If you choose another password for mysql then be careful not to take the default password root when the app is being installed