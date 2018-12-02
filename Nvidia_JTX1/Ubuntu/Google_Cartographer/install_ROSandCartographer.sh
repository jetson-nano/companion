#!/bin/bash

if [ $(id -u) -ne 0 ]; then
   echo >&2 "Must be run as root"
   exit 1
fi

. ../config.env

set -e
set -x

time ./installROSTX2.sh -p ros-kinetic-desktop-full
time ./Install_google_cartographer.sh

echo "Succesfull install_ROSandCartographer.sh"