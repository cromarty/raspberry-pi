#!/bin/bash
#
# This script needs to be run the first time a new Arch Linux image is booted.
#
# First pacman-key is called to both initiate and
# populate the keyrings.
#
# Then pacman -Syu is called for full synch and upgrade.
#
# Before the auto-expansion can run, libnewt and parted need to be
# installed.
#
# At the bottom of this script the call to the auto-expansion
# script is appended to /boot/cmdline.txt
#

# Check we are root
(( EUID == 0 )) || { echo "Script must be run as root" ; exit 1 ; }

set -e

# Initiate and populate keyrings
pacman-key --init
pacman-key --populate

# synch and upgrade
pacman -Syu --noconfirm --noprogress

# Install the auto-expansion script dependencies
pacman -S --noconfirm --noprogressbar --needed libnewt parted

# set up for auto-expansion on next boot
sed -i 's|\(.*\)|\1 init=/usr/lib/raspi-config/init_resize.sh|' /boot/cmdline.txt

#
# Will need Python and dmidecode for configuring this Pi with Ansible
#


exit 0


