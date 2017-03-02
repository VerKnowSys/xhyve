#!/bin/sh

# Linux
# KERNEL="test/vmlinuz"
# INITRD="test/initrd.gz"
# CMDLINE="earlyprintk=serial console=ttyS0"

# FreeBSD
USERBOOT="lib/userboot.so"
BOOTVOLUME="/Data/ISO/HardenedBSD-11-STABLE-v46.15-amd64-memstick.img"
KERNELENV="-v"

MEM="-m 4G"
SMP="-c 4"
# NET="-s 2:0,virtio-net"
# IMG_CD="-s 3,ahci-cd,/Data/ISO/HardenedBSD-11-STABLE-v46.15-amd64-memstick.img"
IMG_HDD="-s 4,virtio-blk,/Data/ISO/HardenedBSD-11-STABLE-v46.15-amd64-memstick.img"
PCI_DEV="-s 0:0,hostbridge -s 31,lpc"
LPC_DEV="-l com1,stdio"
ACPI="-A"
UUID="-U 13725C2F-FF66-4F9D-AD7F-D3FC94FBF40F"

# Linux
# build/xhyve $ACPI $MEM $SMP $PCI_DEV $LPC_DEV $NET $IMG_CD $IMG_HDD $UUID -f kexec,$KERNEL,$INITRD,"$CMDLINE"

# FreeBSD
bin/xhyve $ACPI $MEM $SMP $PCI_DEV $LPC_DEV $NET $IMG_CD $IMG_HDD $UUID -f fbsd,$USERBOOT,$BOOTVOLUME,"$KERNELENV"
