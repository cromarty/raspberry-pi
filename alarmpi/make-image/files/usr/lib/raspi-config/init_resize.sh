#!/bin/sh

reboot_pi () {
  echo "In reboot_pi" >> /root/resize.log
  umount /boot
  mount / -o remount,ro
  sync
  
  echo b > /proc/sysrq-trigger
  sleep 5
  exit 0
}

check_commands () {
  echo "In check_commands" >> /root/resize.log
  if ! command -v whiptail > /dev/null; then
      echo "Whiptail not found" >> /root/resize.log
      echo "whiptail not found"
      sleep 5
      return 1
  fi
  for COMMAND in grep cut sed parted fdisk findmnt partprobe; do
    if ! command -v $COMMAND > /dev/null; then
      FAIL_REASON="$COMMAND not found"
            echo "Failed in check_commands: ${FAIL_REASON}" >> /root/resize.log
      return 1
    fi
  done
  return 0
}

get_variables () {
  echo "In get_variables" >> /root/resize.log
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

###
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
  
}

fix_partuuid() {
  echo "In fix_partuuid" >> /root/resize.log
  DISKID="$(fdisk -l "$ROOT_DEV" | sed -n 's/Disk identifier: 0x\([^ ]*\)/\1/p')"

  echo "Editing /etc/fstab" >> /root/resize.log
  sed -i "s/${OLD_DISKID}/${DISKID}/g" /etc/fstab
    echo "Editing /boot/cmdline.txt" >> /root/resize.log
  sed -i "s/${OLD_DISKID}/${DISKID}/" /boot/cmdline.txt
}

check_variables () {
  echo "In check_variables" >> /root/resize.log
  
  if [ "$BOOT_DEV_NAME" != "$ROOT_DEV_NAME" ]; then
      FAIL_REASON="Boot and root partitions are on different devices"
            echo "Failed in check_variables: ${FAIL_REASON}" >> /root/resize.log
      return 1
  fi

  if [ "$ROOT_PART_NUM" -ne "$LAST_PART_NUM" ]; then
    FAIL_REASON="Root partition should be last partition"
        echo "Failed in check_variables: ${FAIL_REASON}" >> /root/resize.log
    return 1
  fi

  if [ "$ROOT_PART_END" -gt "$TARGET_END" ]; then
    FAIL_REASON="Root partition runs past the end of device"
        echo "Failed in check_variables: ${FAIL_REASON}" >> /root/resize.log
    return 1
  fi

  if [ ! -b "$ROOT_DEV" ] || [ ! -b "$ROOT_PART_DEV" ] || [ ! -b "$BOOT_PART_DEV" ] ; then
    FAIL_REASON="Could not determine partitions"
        echo "Failed in check_variables: ${FAIL_REASON}" >> /root/resize.log
    return 1
  fi
    echo "Exit from check_variables" >> /root/resize.log
}

main () {
  echo "In main" >> /root/resize.log
  get_variables

  if ! check_variables; then
      echo "check_variables returned bad in main" >> /root/resize.log
    return 1
  fi



  if [ "$ROOT_PART_END" -eq "$TARGET_END" ]; then
      echo "ROOT_PART_END and TARGET_END are equal in main" >> /root/resize.log
    reboot_pi
  fi

#  echo "Before call to parted to resize in main" >> /root/resize.log
#  if ! parted -m "$ROOT_DEV" u s resizepart "$ROOT_PART_NUM" "$TARGET_END"; then
#    FAIL_REASON="Root partition resize failed"
#        echo "Failed in main: ${FAIL_REASON}" >> /root/resize.log
#    return 1
#  fi
#
#
#  echo "Before partprobe in main" >> /root/resize.log
#  partprobe "$ROOT_DEV"
  #
#    echo "Before call to fix_partuuid in main" >> /root/resize.log
#  fix_partuuid
  
  echo "Before exit from main" >> /root/resize.log
  return 0
}

echo "Start of init_resize.sh" >> /root/resize.log
echo "Before mounts" >> /root/resize.log
mount -t proc proc /proc
mount -t sysfs sys /sys
mount -t tmpfs tmp /run
mkdir -p /run/systemd

mount /boot
mount / -o remount,rw

echo "Before sed to remove init= from cmdline.txt" >> /root/resize.log
sed -i 's| init=/usr/lib/raspi-config/init_resize.sh||' /boot/cmdline.txt
if ! grep -q splash /boot/cmdline.txt; then
  echo "Before call to sed to remove quiet from cmdline.txt" >> /root/resize.log
  sed -i "s/ quiet//g" /boot/cmdline.txt
fi
sync

echo "Before enable of sysrq" >> /root/resize.log
echo 1 > /proc/sys/kernel/sysrq

if ! check_commands; then
  echo "check_commands returned bad so reboot" >> /root/resize.log
  reboot_pi
fi

if main; then
  echo "Good return from main" >> /root/resize.log
  whiptail --infobox "Resized root filesystem. Rebooting in 5 seconds..." 20 60
  sleep 5
else
  echo "Bad return from main" >> /root/resize.log
  sleep 5
  whiptail --msgbox "Could not expand filesystem\n${FAIL_REASON}" 20 60
fi

echo "Before reboot at bottom of init_resize.sh" >> /root/resize.log
reboot_pi
