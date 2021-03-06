#!/bin/bash

sudo apt-get update
# Install the packages that we need
sudo apt-get -y install git
sudo apt-get -y install cmake 
cd /home/pi
echo "Instalando el repositorio de americo8888"
wget https://github.com/americo8888/display-clone/archive/master.zip

# Unzip the software and copy to the Pi
unzip -o display-clone-master.zip
mv display-clone-master display
rm display-clone-master.zip

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

# Install Waveshare 3.5A DTOVERLAY
cd /home/pi/display/scripts/
sudo cp ./waveshare35a.dtbo /boot/overlays/

# Install Waveshare 3.5B DTOVERLAY
sudo cp ./waveshare35b.dtbo /boot/overlays/

# Install the Waveshare 3.5A driver
sudo bash -c 'cat /home/pi/display/scripts/configs/waveshare_mkr.txt >> /boot/config.txt'

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
