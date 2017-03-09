#!/bin/sh


# use raw zvol disk:
HDD1="/dev/rdisk3" # NOTE: change 3 here for your own one!!
INSTALLER_DISK_IMAGE="/Data/ISO/HardenedBSD-11-STABLE-v46.15-amd64-memstick.img"
BOOTVOLUME="${HDD1}"

IMG_HDD0="-s 4:0,ahci-hd,${INSTALLER_DISK_IMAGE}"
IMG_HDD1="-s 4:1,ahci-hd,${HDD1}"


UUID="-U 13725C2F-FF66-4F9D-AD7F-D3FC94FBF40F"
SMP="-c 8"
MEM="-m 12g"
NET="-s 2:0,virtio-net"
PCI_DEV="-s 0:0,hostbridge"
LPC_DEV="-s 31,lpc -l com1,stdio"
ACPI="-A"
OPTIONS="-H -w"
# EXPERIMENTAL_OPTIONS="-W -x"
KERNELENV=""
ARCH="x86_64"
USERBOOT="lib/userboot.so"


# --------------------------------------------------------------

failure () {
    echo "Boot failure: ${1}"
    exit "${2}"
}

_a_pwd="$(/bin/pwd >/dev/null)"
_pwd="${_a_pwd:-.}"
test -d "${_pwd}/sbin" || failure "Missing ${_pwd}/sbin" 176
test -d "${_pwd}/bin" || failure "Missing ${_pwd}/bin" 177
test -x "${_pwd}/bin/boot.sh" || failure "Missing ${_pwd}/bin/boot.sh" 178

XHYVE_BIN="${_pwd}/sbin/xhyve.${ARCH}"
if [ ! -x "${XHYVE_BIN}" ]; then
    echo "No XHyve binary: ${XHYVE_BIN}. Invoking build process: bin/build-xhyve"
    bin/build-xhyve.sh
fi

# NOTE: sudo is necessary only for NET virtio-net to work :()
sudo "${XHYVE_BIN}" \
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

exit
