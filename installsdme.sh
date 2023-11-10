#!/bin/bash
# 	ScarletDME bash install script
# 	(c) 2023 Donald Montaine
#	This software is released under the Blue Oak Model License
#	a copy can be found on the web here: https://blueoakcouncil.org/license/1.0.0
#
    if [[ $EUID -eq 0 ]]; then
       echo "This script must NOT be run as root" 1>&2
       exit
    fi
#
tgroup=qmusers
tuser=$USER
cwd=$(pwd)
#

clear 
echo ScarletDME installer
echo --------------------
echo
echo
echo "Warning: This installer will overwrite existing files"
echo "         in the /usr/qmsys directory!"
echo
echo "For this install to work you must:"
echo
echo "  1 be running a recent version - 2022 and later"
echo "    of a Redhat, Debian or Arch based distro"
echo
echo "  2 have a build environment installed"
echo "    For Debian run apt get build essential"
echo "    For Redhat run dnf groupinstall 'development tools'"
echo "    For Arch run pacman -S base-devel"
echo
echo "  3 have sudo installed and be a member of the sudo group"
echo
read -p "Continue? (y/n) " yn
case $yn in
	[yY] ) echo;;
	[nN] ) exit;;
	* ) exit ;;
esac
echo
echo If requested, enter your account password:
sudo pwd
clear

#	Unzip sdme.zip into temporary directory
unzip sdme.zip 
cd sdme

#	Run make to created qm executable
make -B

# Create qm system user and group

if getent group qmusers > /dev/null 2>&1; then
    echo "Group qmusers already exists."
else
    echo "Creating group: qmusers"

    if command -v groupadd > /dev/null 2>&1; then
        sudo groupadd --system qmusers
        sudo usermod -a -G qmusers root

    elif command -v addgroup > /dev/null 2>&1; then
        sudo addgroup --system qmusers
        sudo adduser root qmusers
    else
        echo "Failed to create qmusers group."
    fi 
fi

# Create QM User
if getent passwd qmsys > /dev/null 2>&1; then
    echo "User qmsys already exists."
else 
    echo "Creating user: qmsys."

    if command -v useradd > /dev/null 2>&1; then
        sudo useradd --system qmsys -G qmusers
    elif command -v adduser > /dev/null 2>&1; then
        sudo adduser --system qmsys -G qmusers
    else
        echo "Failed to create qmsys user."
    fi
fi

sudo cp -R qmsys /usr
sudo cp -R bin /usr/qmsys
sudo cp -R gplsrc /usr/qmsys
sudo chown -R qmsys:qmusers /usr/qmsys
sudo chown root:root /usr/qmsys
sudo cp scarlet.conf /etc/scarlet.conf
sudo chmod 644 /etc/scarlet.conf
sudo chmod -R 775 /usr/qmsys
sudo chmod 775 /usr/qmsys/bin
sudo chmod 775 /usr/qmsys/bin/*

sudo ln -s /usr/qmsys/bin/qm /usr/bin/qm

# Install scarletdme.service for systemd
SYSTEMDPATH=/usr/lib/systemd/system

if [ -d  "$SYSTEMDPATH" ]; then
    if [ -f "$SYSTEMDPATH/scarletdme.service" ]; then
        echo "ScarletDME systemd service is already installed."
    else
        echo "Installing scarletdme.service for systemd."
	
        sudo cp usr/lib/systemd/system/* $SYSTEMDPATH

        sudo chown root:root $SYSTEMDPATH/scarletdme.service
        sudo chown root:root $SYSTEMDPATH/scarletdmeclient.socket
        sudo chown root:root $SYSTEMDPATH/scarletdmeclient@.service
        sudo chown root:root $SYSTEMDPATH/scarletdmeserver.socket
        sudo chown root:root $SYSTEMDPATH/scarletdmeserver@.service

        sudo chmod 644 $SYSTEMDPATH/scarletdme.service
        sudo chmod 644 $SYSTEMDPATH/scarletdmeclient.socket
        sudo chmod 644 $SYSTEMDPATH/scarletdmeclient@.service
        sudo chmod 644 $SYSTEMDPATH/scarletdmeserver.socket
        sudo chmod 644 $SYSTEMDPATH/scarletdmeserver@.service

 	sudo systemctl enable scarletdme.service
	sudo systemctl enable scarletdmeclient.socket
	sudo systemctl enable scarletdmeserver.socket
	sudo systemctl start scarletdme.service
	sudo systemctl start scarletdmeclient.socket
	sudo systemctl start scarletdmeserver.socket
    fi
fi

#	Add $tuser to qmusers group
sudo usermod -aG qmusers $tuser

#	Start ScarletDME server
sudo /usr/qmsys/bin/qm -start
cd /usr/qmsys
sudo bin/qm -internal FIRST.COMPILE
cd $cwd

#	Remove temporary sdme install directory
rm -fr sdme
echo
echo
echo -----------------------------------------------------
echo "The ScarletDME server is installed."
echo "Log out and back in or reboot to assure that" 
echo "group memberships are updated."
echo
echo "To completely delete ScarletDME, run the" 
echo "deletesdme.sh bash script provided."
echo
echo "Afterward, open a terminal and enter 'qm' in your"
echo "desired qm home directory."
echo -----------------------------------------------------
echo
exit
