#!/bin/bash

(( EUID == 0 )) || { echo "Script must be run as root" ; exit 1 ; }

pacman -S --noconfirm --noprogressbar --needed \
    sudo python dmidecode dosfstools rsync

sed -i 's|#\( %wheel ALL=(ALL) ALL\)|\1|' /etc/sudoers

