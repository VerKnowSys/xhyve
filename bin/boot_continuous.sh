#!/bin/sh

check_nostart () {
    if [ -f ".nostart" ]; then
        rm -f ".nostart"
        echo "Requested bin/shutdown, continuous mode stopped."
        exit
    fi
}

while true; do
    clear
    reset
    echo "Booting xHyve…"
    bin/boot.sh
    echo "Shutdown completed"
    check_nostart
done
exit
