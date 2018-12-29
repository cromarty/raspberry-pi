#!/bin/bash

(( EUID == 0 )) || { echo "Script must be run as root" ; exit 1 ; }

set -e


pacman-key --init
pacman-key --populate

pacman -S --noconfirm --noprogressbar --needed libnewt parted

# set up for auto-expansion on next boot
sed -i 's|\(.*\)|\1 init=/usr/lib/raspi-config/init_resize.sh|' /boot/cmdline.txt

#
# Will need Python and dmidecode for configuring this Pi with Ansible
#


exit 0


