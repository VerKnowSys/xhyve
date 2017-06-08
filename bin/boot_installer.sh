#!/bin/sh


bin/shutdown

echo "Enabling installer image for boot"
sed -i '' \
    -e 's|BOOTVOLUME="${VD_CURRENT}"|BOOTVOLUME="${INSTALLER_CURRENT}"|g; s|BOOTVOLUME="${VD_STABLE}"|BOOTVOLUME="${INSTALLER_STABLE}"|g;' \
    bin/boot.sh 2>/dev/null

bin/boot.sh "${1}"

echo "Switch to default boot device"
sed -i '' \
    -e 's|BOOTVOLUME="${INSTALLER_CURRENT}"|BOOTVOLUME="${VD_CURRENT}"|g; s|BOOTVOLUME="${INSTALLER_STABLE}"|BOOTVOLUME="${VD_STABLE}"|g;' \
    bin/boot.sh 2>/dev/null

echo
echo "Run bin/boot_continuous.sh to boot default environment"
echo
exit 0
