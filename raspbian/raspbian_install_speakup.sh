#!/bin/bash
#
# Prepares Raspbian for console speech output with speakup.
#
# Installs espeakup from source and prepares service files, and starts espeakup.
#
# Needs to be run as root.
#

set -e

(( EUID == 0 )) || {
    echo "This script must be run as root. Try 'sudo ./raspbian_install_speakup.sh'"
    exit 1
}

echo "Running update..."
apt-get update


echo "Installing necessary packages..."
apt-get install -y --no-install-recommends --no-install-suggests \
    build-essential espeak libespeak-dev git

echo "Cloning espeakup from git..."
git clone --depth 1 https://github.com/williamh/espeakup.git
cd espeakup
make
make install
cd ..
rm -rf espeakup/

echo "Writing /etc/default/espeakup..."
cat <<EOF > /etc/default/espeakup
# To choose the default voice of the espeakup daemon, define VOICE here.
# See /usr/lib/*/espeak-data/voices/ for a list of possible voices.

VOICE=m1

# To choose audio output on another sound card, uncomment this and set as
# appropriate (either a card number or a card name as seen in CARD= alsa
# output).
#
# export ALSA_CARD=0

EOF

echo "Writing /lib/systemd/system/espeakup.service..."
cat <<EOF > /lib/systemd/system/espeakup.service
[Unit]
Description=Software speech output for Speakup
# espeakup needs to start after the audio devices appear, hopefully this should go away in the future
Wants=systemd-udev-settle.service
After=systemd-udev-settle.service sound.target

[Service]
Type=forking
PIDFile=/run/espeakup.pid
EnvironmentFile=-/etc/default/espeakup
ExecStart=/usr/local/bin/espeakup -V $VOICE
ExecReload=/bin/kill -HUP $MAINPID
Restart=always

[Install]
WantedBy=sound.target

EOF


# speakup kernel modules need to be loaded before we can start espeakup
echo "Load speakup for this session..."
modprobe speakup_soft

echo "Enable espeakup..."
systemctl enable espeakup.service

echo "Start espeakup..."
systemctl start espeakup

echo "Writing /etc/modules-load.d/speakup.conf..."
cat <<EOF > /etc/modules-load.d/speakup.conf
speakup_soft

EOF


echo "All done. Now reboot."





