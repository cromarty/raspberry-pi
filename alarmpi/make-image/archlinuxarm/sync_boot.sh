#!/bin/bash

(( EUID == 0 )) || { echo "Script must be run as root" ; exit 1 ; }

set -e

sourcebootmp=./source/boot
sourcerootmp=./source/root

targetbootmp=./target/boot
targetrootmp=./target/root

rsync --archive --verbose \
		--compress --delete \
		--progress --one-file-system \
		--human-readable \
		${sourcebootmp}/* ${targetbootmp}

sync

exit 0

