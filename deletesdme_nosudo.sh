#!/bin/bash
#
# 	ScarletDME bash delete script
# 	(c) 2023 Donald Montaine
#	This software is released under the Blue Oak Model License
#	a copy can be found on the web here: https://blueoakcouncil.org/license/1.0.0
#
    if [[ $EUID -ne 0 ]]; then
       echo "This script must be run as root" 1>&2
       exit
    fi
    if [ -f  "/usr/qmsys/bin/qm" ]; then
		echo
	else
		echo "QM is not installed!"
		echo "This script will not run."
		exit
	fi
#
clear
echo REMOVE ScarletDME Completely
echo -----------------------------------------
	read -p "Are you sure? (y/n) " yn
	case $yn in
		[yY] ) echo;;
		[nN] ) break;;
		* ) break;;
	esac
# remove the /usr/qmsys directory
sudo rm -fr /usr/qmsys
echo
echo "Removed /usr/qmsys directory."
# remove the symbolic link to qm in /usr/bin
rm /usr/bin/qm
echo "Removed symbolic link /usr/bin/qm."
cd /usr/lib/systemd/system
#stop services
systemctl stop scarletdme.service
systemctl stop scarletdmeclient.socket
systemctl stop scarletdmeserver.socket
# disable services
systemctl disable scarletdme.service
systemctl disable scarletdmeclient.socket
systemctl disable scarletdmeserver.socket
# remove service files
rm /usr/lib/systemd/system/scarletdme*
echo "Removed systemd service files."
# remove qmsys user and qmusers group
echo "Removed qmsys user and qmusers group."
userdel qmsys
groupdel qmusers
echo "Removed qmsys user and qmusers group."
echo
echo -----------------------------------------
echo "Deletesdme_nosudo.sh script completed."
echo "Logout/in or reboot to update"
echo "user and group information."
echo
