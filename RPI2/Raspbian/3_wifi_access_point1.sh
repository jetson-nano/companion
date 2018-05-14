#!/bin/bash

# RPi2 setup script for use as companion computer

if [ $(id -u) -ne 0 ]; then
   echo >&2 "Must be run as root"
   exit 1
fi

set -e
set -x

pushd $HOME

pip install netifaces
pip install eventlet flask flask_socketio redis

apt-get install -y python-dbus python-netifaces python-pexpect wpasupplicant hostapd wireless-tools udhcpd udhcpc
apt-get install -y dbus libdbus-glib-1-dev libdbus-1-dev python-dbus redis-tools

sudo apt-get install avahi-daemon

pushd GitHub/companion/RPI2/Raspbian/WiFiControl
cp
