#!/bin/bash

if [ $(id -u) -ne 0 ]; then
   echo >&2 "Must be run as root"
   exit 1
fi

set -e
set -x

. config.env

if [ -e /etc/wpa_supplicant/wpa_supplicant.conf ]; then
    mv /etc/wpa_supplicant/wpa_supplicant.conf{,-unused}
fi
systemctl stop wpa_supplicant
systemctl disable wpa_supplicant
killall /sbin/wpa_supplicant || true

# most of this is common:
../../Common/Ubuntu/3_wifi_access_point.sh
