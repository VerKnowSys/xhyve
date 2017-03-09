#!/bin/sh

while true; do
    clear
    reset
    echo "Booting xHyve…"
    bin/boot.sh
    echo "Shutdown completed"
done
exit
