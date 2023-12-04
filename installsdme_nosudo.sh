#!/bin/bash
# 	ScarletDME bash install script without sudo
# 	(c) 2023 Donald Montaine
#	This software is released under the Blue Oak Model License
#	a copy can be found on the web here: https://blueoakcouncil.org/license/1.0.0
#
    if [[ $EUID -ne 0 ]]; then
       echo "This script must be run as root" 1>&2
       exit
    fi
    if [ -f  "/usr/qmsys/bin/qm" ]; then
		echo "A version of qm is already installed."
		echo "Uninstall it before running this script."
		exit
	fi
#
cwd=$(pwd)
#

clear 
echo ScarletDME installer
echo --------------------
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
read -p "Continue? (y/n) " yn
case $yn in
	[yY] ) echo;;
	[nN] ) exit;;
	* ) exit ;;
esac
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
        groupadd --system qmusers
        usermod -a -G qmusers root

    elif command -v addgroup > /dev/null 2>&1; then
        addgroup --system qmusers
        adduser root qmusers
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
        useradd --system qmsys -G qmusers
    elif command -v adduser > /dev/null 2>&1; then
        adduser --system qmsys -G qmusers
    else
        echo "Failed to create qmsys user."
    fi
fi

cp -R qmsys /usr
cp -R bin /usr/qmsys
cp -R gplsrc /usr/qmsys
cp -R gplobj /usr/qmsys
cp -R terminfo /usr/qmsys
cp Makefile /usr/qmsys
cp gpl.src /usr/qmsys
cp terminfo.src /usr/qmsys
chown -R qmsys:qmusers /usr/qmsys
chown -R qmsys:qmusers /usr/qmsys/terminfo
chown root:root /usr/qmsys
cp scarlet.conf /etc/scarlet.conf
chmod 644 /etc/scarlet.conf
chmod -R 775 /usr/qmsys
chmod 775 /usr/qmsys/bin
chmod 775 /usr/qmsys/bin/*

ln -s /usr/qmsys/bin/qm /usr/bin/qm

# Install scarletdme.service for systemd
SYSTEMDPATH=/usr/lib/systemd/system

if [ -d  "$SYSTEMDPATH" ]; then
    if [ -f "$SYSTEMDPATH/scarletdme.service" ]; then
        echo "ScarletDME systemd service is already installed."
    else
        echo "Installing scarletdme.service for systemd."
	
        cp usr/lib/systemd/system/* $SYSTEMDPATH

        chown root:root $SYSTEMDPATH/scarletdme.service
        chown root:root $SYSTEMDPATH/scarletdmeclient.socket
        chown root:root $SYSTEMDPATH/scarletdmeclient@.service
        chown root:root $SYSTEMDPATH/scarletdmeserver.socket
        chown root:root $SYSTEMDPATH/scarletdmeserver@.service

        chmod 644 $SYSTEMDPATH/scarletdme.service
        chmod 644 $SYSTEMDPATH/scarletdmeclient.socket
        chmod 644 $SYSTEMDPATH/scarletdmeclient@.service
        chmod 644 $SYSTEMDPATH/scarletdmeserver.socket
        chmod 644 $SYSTEMDPATH/scarletdmeserver@.service

 	    systemctl enable scarletdme.service
	    systemctl enable scarletdmeclient.socket
	    systemctl enable scarletdmeserver.socket
	    systemctl start scarletdme.service
	    systemctl start scarletdmeclient.socket
	    systemctl start scarletdmeserver.socket
    fi
fi

#	Start ScarletDME server
/usr/qmsys/bin/qm -start
cd /usr/qmsys
bin/qm -internal FIRST.COMPILE
cd $cwd

#	Remove temporary sdme install directory
rm -fr sdme
echo
echo
echo -----------------------------------------------------
echo "The ScarletDME server is installed."
echo
echo "Enter: usermod -aG qmusers <yourusername>" to add
echo "your user to the qmusers group."
echo
echo "Reboot to assure that group memberships are updated."
echo
echo "Afterward, open a terminal and enter 'qm' in your"
echo "desired qm home directory."
echo -----------------------------------------------------
echo
echo "To completely delete ScarletDME, run the" 
echo "deletesdme_nosudo.sh bash script provided."

echo
exit
