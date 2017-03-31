#!/bin/sh


RELEASE="${1:-stable}"
VD_SIZE="40g" # GiB
UUID="-U 13725C2F-FF66-4F9D-AD7F-D3FC94FBF40F"
SMP="-c 7"
MEM="-m 10g"
NET="-s 2:0,virtio-net"
PCI_DEV="-s 0:0,hostbridge"
LPC_DEV="-s 31,lpc -l com1,stdio"
ACPI="-A"
OPTIONS="-H -w"
# EXPERIMENTAL_OPTIONS="-W -x"
KERNELENV=""
ARCH="x86_64"
USERBOOT="lib/userboot.so"

INSTALLER_STABLE="/Data/ISO/HardenedBSD-11-STABLE-v46.16-amd64-memstick.img"
INSTALLER_CURRENT="${INSTALLER_STABLE}"

if [ "Darwin" = "$(uname 2>/dev/null)" ]; then
    mkdir -p "${HOME}/Library/VMS"
    VD_CURRENT="${HOME}/Library/VMS/xh_current.vd"
    VD_STABLE="${HOME}/Library/VMS/xh_stable.vd"
    if [ "dmilith" = "${USER}" ]; then
        VD_CURRENT="/dev/rdisk3" # Use ZVOL
    fi
else
    mkdir -p "${HOME}/.VMS"
    VD_CURRENT="${HOME}/.VMS/xh_current.vd"
    VD_STABLE="${HOME}/.VMS/xh_stable.vd"
fi

if [ "stable" = "${RELEASE}" ]; then
    IMG_HDD0="-s 4:0,ahci-hd,${INSTALLER_STABLE}"
    IMG_HDD1="-s 4:1,ahci-hd,${VD_STABLE}"
    BOOTVOLUME="${VD_STABLE}"
else
    IMG_HDD0="-s 4:0,ahci-hd,${INSTALLER_CURRENT}"
    IMG_HDD1="-s 4:1,ahci-hd,${VD_CURRENT}"
    BOOTVOLUME="${VD_CURRENT}"
fi

if [ ! -f "${VD_STABLE}" ]; then
    echo "Found no virtual disk file: ${VD_STABLE}. It will be created and initialized with size: ${VD_SIZE}GiB"
    dd -v if=/dev/zero of="${VD_STABLE}" bs=1 count=0 seek=${VD_SIZE}g
fi

echo "System release: ${RELEASE}"
echo "Boot volume: ${BOOTVOLUME}"
echo "CPUs: ${SMP}"
echo "MEM: ${MEM}"

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
sudo -- "${XHYVE_BIN}" \
    ${UUID} \
    ${ACPI} \
    ${MEM} \
    ${SMP} \
    ${PCI_DEV} \
    ${LPC_DEV} \
    ${NET} \
    ${IMG_HDD0} \
    ${IMG_HDD1} \
    ${OPTIONS} \
    ${EXPERIMENTAL_OPTIONS} \
    -f fbsd,${USERBOOT},${BOOTVOLUME},"${KERNELENV}"

exit
