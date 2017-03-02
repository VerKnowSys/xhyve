#!/bin/sh

USERBOOT="lib/userboot.so"
KERNELENV=""

# FreeBSD installer disk:
HDD0="/Data/ISO/HardenedBSD-11-STABLE-v46.15-amd64-memstick.img"

# FreeBSD data disk:
HDD1="/Studio/VMs/xhyve.disks/xhyve1.dmg"

IMG_HDD0="-s 4:0,ahci-hd,${HDD0}"
IMG_HDD1="-s 4:1,ahci-hd,${HDD1}"

BOOTVOLUME="${HDD1}"

MEM="-m 4G"
SMP="-c 4"
NET="-s 2:0,virtio-net"
PCI_DEV="-s 0:0,hostbridge -s 31,lpc"
LPC_DEV="-l com1,stdio"
ACPI="-A"
UUID="-U 13725C2F-FF66-4F9D-AD7F-D3FC94FBF40F"

# start HardenedBSD:
sudo bin/xhyve $ACPI $MEM $SMP $PCI_DEV $LPC_DEV $NET $IMG_CD $IMG_HDD0 $IMG_HDD1 $UUID -f fbsd,$USERBOOT,$BOOTVOLUME,"$KERNELENV"

# NOTE: sudo is necessary for NET virtio-net to work :()
