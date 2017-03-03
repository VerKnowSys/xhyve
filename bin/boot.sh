#!/bin/sh

USERBOOT="lib/userboot.so"
KERNELENV=""

# FreeBSD installer disk:
INSTALLER_DISK_IMAGE="/Data/ISO/HardenedBSD-11-STABLE-v46.15-amd64-memstick.img"
BASE_DISK_IMAGE=""

# FreeBSD data disk:
#
# > zfs create -sV 50g Studio/VMs/xhyve-1.zvol
# > ioreg -trn "ZVOL Studio/VMs/xhyve-1.zvol Media" | grep "BSD Name" to find out assigned /dev/[r]diskN
HDD1="/Studio/VMs/xh1.zvol"

IMG_HDD0="-s 4:0,ahci-hd,${INSTALLER_DISK_IMAGE}"
IMG_HDD1="-s 4:1,ahci-hd,${HDD1}"

BOOTVOLUME="${HDD1}"

UUID="-U 13725C2F-FF66-4F9D-AD7F-D3FC94FBF40F"
SMP="-c 4"
MEM="-m 6144"
NET="-s 2:0,virtio-net"
PCI_DEV="-s 0:0,hostbridge"
LPC_DEV="-s 31,lpc -l com1,stdio"
ACPI="-A"
OPTIONS="-H -w"
# EXPERIMENTAL_OPTIONS="-W -x"

#
# start HardenedBSD:
# NOTE: sudo is necessary only for NET virtio-net to work :()
sudo bin/xhyve \
    ${UUID} \
    ${ACPI} \
    ${MEM} \
    ${SMP} \
    ${PCI_DEV} \
    ${LPC_DEV} \
    ${NET} \
    ${IMG_CD} \
    ${IMG_HDD0} \
    ${IMG_HDD1} \
    ${OPTIONS} \
    ${EXPERIMENTAL_OPTIONS} \
    -f fbsd,${USERBOOT},${BOOTVOLUME},"${KERNELENV}"

