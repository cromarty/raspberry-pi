#!/bin/bash


join() {
    local IFS="$1"
    shift
    echo "$*"
}


set -e

(( EUID == 0 )) || { echo "Script must be run as root" ; exit 1 ; }

hash pacstrap &>/dev/null || {
    echo "Could not find pacstrap. Run pacman -S arch-install-scripts"
    exit 1
}



export LANG="C.UTF-8"

ROOTFS=/mnt/usb2/arse

mkdir -p "${ROOTFS}"

chmod 755 ${ROOTFS}

# packages to ignore for space savings
PKGEXCLUDE=$(<exclude.pkglist)
PKGEXCLUDE=$(join , ${PKGEXCLUDE[*]})

arch="$(uname -m)"

PACMAN_CONF=$(mktemp /tmp/pacman-conf-archlinux-XXXXXXXXX)

# extra packages to include
PKGEXTRA=$(<extra.pkglist)
PKGEXTRA=$(join " " ${PKGEXTRA[*]})


case "$arch" in
	armv*)
		echo "=== Architecture is either armv6 or armv7"
		version="$(echo $arch | cut -c 5)"
		sed "s/Architecture = armv/Architecture = armv${version}h/g" './mkimage-archarm-pacman.conf' > "${PACMAN_CONF}"
		ARCH_KEYRING=archlinuxarm
	;;
	aarch64)
		echo "=== Architecture is aarch64"
		sed "s/Architecture = armv/Architecture = aarch64/g" './mkimage-archarm-pacman.conf' > "${PACMAN_CONF}"
		ARCH_KEYRING=archlinuxarm
;;
	*)
		echo "Not running on a Raspberry Pi"
		exit 1
		;;
esac




#pacstrap -d ${ROOTFS} -C ${PACMAN_CONF} -c -G --ignore ${PKGEXCLUDE} base haveged ${PKGEXTRA} --noconfirm --needed --noprogress
pacstrap -d ${ROOTFS} -C ${PACMAN_CONF} -c -G base haveged ${PKGEXTRA} --noconfirm --needed --noprogress

# Some of these arch-chroots have a `touch` command at the end. Bizarrely I had to add
# these to stop the arch-chroot from failing the script. No idea why
arch-chroot ${ROOTFS} /bin/sh -c "haveged -w 1024; pacman-key --init; pkill haveged; touch ."
arch-chroot ${ROOTFS} /bin/sh -c "pacman-key --populate ${ARCH_KEYRING}; pkill gpg-agent; touch ."
arch-chroot $ROOTFS /bin/sh -c "rm /etc/localtime"
arch-chroot $ROOTFS /bin/sh -c "ln -s /usr/share/zoneinfo/UTC /etc/localtime"
echo 'en_GB.UTF-8 UTF-8' > $ROOTFS/etc/locale.gen
arch-chroot $ROOTFS locale-gen
arch-chroot $ROOTFS /bin/sh -c "ln -s /lib/systemd/systemd /usr/bin/init"

mknod -m 666 $DEV/null c 1 3
mknod -m 666 $DEV/zero c 1 5
mknod -m 666 $DEV/random c 1 8
mknod -m 666 $DEV/urandom c 1 9
mkdir -m 755 $DEV/pts
mkdir -m 1777 $DEV/shm
mknod -m 666 $DEV/tty c 5 0
mknod -m 600 $DEV/console c 5 1
mknod -m 666 $DEV/tty0 c 4 0
mknod -m 666 $DEV/full c 1 7
mknod -m 600 $DEV/initctl p
mknod -m 666 $DEV/ptmx c 5 2
ln -sf /proc/self/fd $DEV/fd

exit 0

