#!/bin/sh

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

echo
echo "Run bin/boot_continuous.sh to boot default environment"
echo
exit 0
