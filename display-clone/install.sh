#!/bin/bash

# Update the package manager
sudo dpkg --configure -a
sudo apt-get update

# Uninstall the apt-listchanges package to allow silent install of ca certificates (201704030)
# http://unix.stackexchange.com/questions/124468/how-do-i-resolve-an-apparent-hanging-update-process
sudo apt-get -y remove apt-listchanges

# -------- Upgrade distribution ------

# Update the distribution
sudo apt-get -y dist-upgrade

# Install the packages that we need
sudo apt-get -y install git
sudo apt-get -y install cmake 
cd /home/pi
echo "Installing development load"
wget https://github.com/americo8888/display-clone/archive/master.zip

# Unzip the rpidatv software and copy to the Pi
unzip -o master.zip
mv -master display
rm master.zip

# TouchScreen GUI
# FBCP : Duplicate Framebuffer 0 -> 1
cd /home/pi/
wget https://github.com/tasanakorn/rpi-fbcp/archive/master.zip
unzip master.zip
mv rpi-fbcp-master rpi-fbcp
rm master.zip

# Compile fbcp
cd rpi-fbcp/
mkdir build
cd build/
cmake ..
make
sudo install fbcp /usr/local/bin/fbcp
cd ../../

# Install omxplayer
sudo apt-get -y install omxplayer

# Install Waveshare 3.5A DTOVERLAY
cd /home/pi/display/scripts/
sudo cp ./waveshare35a.dtbo /boot/overlays/

# Install Waveshare 3.5B DTOVERLAY
sudo cp ./waveshare35b.dtbo /boot/overlays/

# Install the Waveshare 3.5A driver
sudo bash -c 'cat /home/pi/display/scripts/configs/waveshare_mkr.txt >> /boot/config.txt'

# Download, compile and install the executable for hardware shutdown button
# Updated version that is less trigger-happy (201705200)
git clone https://github.com/philcrump/pi-sdn /home/pi/pi-sdn-build
# Install new version that sets swapoff
cp -f /home/pi/rpidatv/src/pi-sdn/main.c /home/pi/pi-sdn-build/main.c
cd /home/pi/pi-sdn-build
make
mv pi-sdn /home/pi/
cd /home/pi

# Create directory for Autologin link
sudo mkdir -p /etc/systemd/system/getty.target.wants

# Always auto-logon and run .bashrc (and hence startup.sh) (201704160)
sudo ln -fs /etc/systemd/system/autologin@.service\
 /etc/systemd/system/getty.target.wants/getty@tty1.service

# Reboot
printf "\nA reboot is required before using the software\n\n"
printf "Rebooting\n\n"
printf "If fitted, the touchscreen will be active on reboot\n"
sudo reboot now
exit
