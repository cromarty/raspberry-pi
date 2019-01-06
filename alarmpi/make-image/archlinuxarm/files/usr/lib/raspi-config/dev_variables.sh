#!/bin/sh

(( EUID == 0 )) || { echo 'Script must be run as root' ; exit 1 ; }

set -e

echo -e "Device variables\n\n"

ROOT_PART_DEV=$(findmnt / -o source -n)
ROOT_PART_NAME=$(echo "$ROOT_PART_DEV" | cut -d "/" -f 3)
ROOT_DEV_NAME=$(echo /sys/block/*/"${ROOT_PART_NAME}" | cut -d "/" -f 4)
ROOT_DEV="/dev/${ROOT_DEV_NAME}"
ROOT_PART_NUM=$(cat "/sys/block/${ROOT_DEV_NAME}/${ROOT_PART_NAME}/partition")

BOOT_PART_DEV=$(findmnt /boot -o source -n)
BOOT_PART_NAME=$(echo "$BOOT_PART_DEV" | cut -d "/" -f 3)
BOOT_DEV_NAME=$(echo /sys/block/*/"${BOOT_PART_NAME}" | cut -d "/" -f 4)
BOOT_PART_NUM=$(cat "/sys/block/${BOOT_DEV_NAME}/${BOOT_PART_NAME}/partition")

OLD_DISKID=$(fdisk -l "$ROOT_DEV" | sed -n 's/Disk identifier: 0x\([^ ]*\)/\1/p')

echo "ROOT_PART_DEV:${ROOT_PART_DEV}" >> /root/resize.log
echo "ROOT_PART_NAME:${ROOT_PART_NAME}" >> /root/resize.log
echo "ROOT_DEV_NAME:${ROOT_DEV_NAME}" >> /root/resize.log
echo "ROOT_DEV:${ROOT_DEV}" >> /root/resize.log
echo "ROOT_PART_NUM:${ROOT_PART_NUM}" >> /root/resize.log

echo "BOOT_PART_DEV:${BOOT_PART_DEV}" >> /root/resize.log
echo "BOOT_PART_NAME:${BOOT_PART_NAME}" >> /root/resize.log
echo "BOOT_DEV_NAME:${BOOT_DEV_NAME}" >> /root/resize.log
echo "BOOT_PART_NUM:${BOOT_PART_NUM}" >> /root/resize.log

echo "OLD_DISKID:${OLD_DISKID}" >> /root/resize.log

ROOT_DEV_SIZE=$(cat "/sys/block/${ROOT_DEV_NAME}/size")
TARGET_END=$((ROOT_DEV_SIZE - 1))


echo "ROOT_DEV_SIZE:${ROOT_DEV_SIZE}" >> /root/resize.log
echo "TARGET_END:${TARGET_END}" >> /root/resize.log

PARTITION_TABLE=$(parted -m "$ROOT_DEV" unit s print | tr -d 's')
echo -e "Partition table:\n${PARTITION_TABLE}" >> /root/resize.log
LAST_PART_NUM=$(echo "$PARTITION_TABLE" | tail -n 1 | cut -d ":" -f 1)

ROOT_PART_LINE=$(echo "$PARTITION_TABLE" | grep -e "^${ROOT_PART_NUM}:")
ROOT_PART_START=$(echo "$ROOT_PART_LINE" | cut -d ":" -f 2)
ROOT_PART_END=$(echo "$ROOT_PART_LINE" | cut -d ":" -f 3)

echo "ROOT_PART_START:${ROOT_PART_START}" >> /root/resize.log
echo "ROOT_PART_END:${ROOT_PART_END}" >> /root/resize.log
