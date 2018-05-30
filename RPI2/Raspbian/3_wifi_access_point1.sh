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
apt-get install avahi-daemon

pushd GitHub/
git clone https://github.com/jmachuca77/pywificontrol.git
git clone https://github.com/emlid/systemd-manager.git

pushd systemd-manager
python setup.py build install
popd

pushd pywificontrol
git checkout Ardupilot_v0.4.0
python setup.py build install

pushd tools/wpa_supplicant
cp * /etc/wpa_supplicant
popd

pushd tools/hostapd
cp * /etc/hostapd
popd

chmod +x /etc/wpa_supplicant/*.sh
chmod +x /etc/hostapd/*.sh

pushd tools
cp *.service /lib/systemd/system

pushd server
cp -r * /home/apsync/start_wificontrol/


sudo -u $NORMAL_USER -H bash <<'EOF'
set -e
set -x

# auto start wificontrol and server
WIFICONTROL_HOME=~/start_wificontrol
if [ ! -d $WIFICONTROL_HOME ]; then
    mkdir $WIFICONTROL_HOME
fi
cp startup_wifiserver.sh $WIFICONTROL_HOME/
cp init_wifi.py $WIFICONTROL_HOME/

chmod +x $WIFICONTROL_HOME/init_wifi.py
chmod +x $WIFICONTROL_HOME/startup_WifiServer.sh

LINE="# sudo -H -u $NORMAL_USER /bin/bash -c '~$NORMAL_USER/start_wificontrol/startup_WifiServer.sh'"
perl -pe "s%^exit 0%$LINE\\n\\nexit 0%" -i /etc/rc.local

systemctl disable networking
systemctl disable dhcpcd
