#!/bin/bash
#
# 	ScarletDME bash delete script
# 	(c) 2023 Donald Montaine
#	This software is released under the Blue Oak Model License
#	a copy can be found on the web here: https://blueoakcouncil.org/license/1.0.0
#
    if [[ $EUID -eq 0 ]]; then
       echo "This script must NOT be run as root" 1>&2
       exit 1
    fi
#
clear
echo REMOVE ScarletDME Completely
echo ----------------------------
	read -p "Are you sure? (y/n) " yn
	case $yn in
		[yY] ) echo;;
		[nN] ) break;;
		* ) break;;
	esac
# remove the qm directory for the current user
cd ~
rm -fr qm_$USER
# remove the /usr/qmsys directory
sudo rm -fr /usr/qmsys
# remove the symbolic link to qm in /usr/bin
sudo rm /usr/bin/qm
cd /usr/lib/systemd/system
#stop services
sudo systemctl stop scarletdme.service
sudo systemctl stop scarletdmeclient.socket
sudo systemctl stop scarletdmeserver.socket
# disable services
sudo systemctl disable scarletdme.service
sudo systemctl disable scarletdmeclient.socket
sudo systemctl disable scarletdmeserver.socket
# remove service files
sudo rm /usr/lib/systemd/system/scarletdme*
# remove qmsys user and qmusers group
sudo userdel qmsys
sudo groupdel qmusers


