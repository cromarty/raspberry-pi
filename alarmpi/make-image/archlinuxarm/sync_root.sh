#!/bin/bash

(( EUID == 0 )) || { echo "Script must be run as root" ; exit 1 ; }

set -e

sourcebootmp=./source/boot
sourcerootmp=./source/root

targetbootmp=./target/boot
targetrootmp=./target/root

rsync  	--archive --verbose \
		--compress --delete \
		--progress --human-readable --one-file-system \
		--exclude=${sourcerootmp}/lost+found \
		${sourcerootmp}/ "${targetrootmp}"

# Truncate instances of .bash_history to zero size
find "${targetrootmp}/root" -name .bash_history -exec truncate -s 0 {} \;
find "${targetrootmp}/home" -name .bash_history -exec truncate -s 0 {} \;

sync

exit 0

