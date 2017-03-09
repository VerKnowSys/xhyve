#!/bin/sh


DEFAULT_ORIGIN="Studio/VMs/xhyve-1.zvol@origin"


bin/shutdown

echo "Enabling installer image for boot"
sed -i '' \
    -e 's|BOOTVOLUME="${HDD1}"|BOOTVOLUME="${INSTALLER_DISK_IMAGE}"|g;' \
    bin/boot.sh \
    2>/dev/null

bin/boot.sh

echo "Switch default boot device to 'HDD1'"
sed -i '' \
    -e 's|BOOTVOLUME="${INSTALLER_DISK_IMAGE}"|BOOTVOLUME="${HDD1}"|g;' \
    bin/boot.sh \
    2>/dev/null

zfs list -t snap "${DEFAULT_ORIGIN}" >/dev/null 2>&1
if [ "${?}" != "0" ]; then
    echo "Creating 'origin' snapshot: ${DEFAULT_ORIGIN}, after installation process."
    zfs snapshot "${DEFAULT_ORIGIN}"
fi

echo
echo "Run bin/boot_continuous.sh to boot default environment"
echo
exit 0
