#!/bin/bash

if [ $(id -u) -ne 0 ]; then
   echo >&2 "Must be run as root"
   exit 1
fi

set -e
set -x

. config.env

apt update
apt upgrade -y

apt install nano rsync

tput setaf 3
echo "Cloning Companion Repo"
tput sgr0

pushd /home/$NORMAL_USER

pushd /home/$NORMAL_USER/GitHub/companion/Nvidia_Nano/Ubuntu

tput setaf 3
echo "Running Scripts"
tput sgr0

tput setaf 3
echo "Removing unused packages"
tput sgr0
time apt autoremove -y # avoid repeated no-longer-required annoyance
time ./remove-unattended-upgrades

tput setaf 3
echo "Setting up rc.local"
tput sgr0
./ensure_rc_local.sh

tput setaf 3
echo "Disabling TTY console on serial port"
tput sgr0
./disable_console.sh

tput setaf 3
echo "Installing AP Sync Packages"
tput sgr0
time sudo -E ./2_install_packages.sh # 20m

tput setaf 3
echo "Installing AP Sync niceties"
tput sgr0
time sudo -E ./install_niceties || echo "Failed" # 20s

# tput setaf 3
# echo "Installing AP Streamlinke"
# tput sgr0
# time ./apstreamline.sh # 1m  This is optional
# #time ./setup-video-streaming # 11s  This is optional

tput setaf 3
echo "Installing Mavlink-Router"
tput sgr0
#time ./setup_mavlink-router # ~2m Remember to change the mavlink_router.conf file to the right serial port
time ./setup_master_mavlink-router.sh

tput setaf 3
echo "Installing dflogger"
tput sgr0
time ./7_dflogger.sh # ~210s

tput setaf 3
echo "Setting up Mavproxy"
tput sgr0
time ./5_setup_mavproxy.sh # instant

tput setaf 3
echo "Setting up pymavlink"
tput sgr0
time apt-get install -y libxml2-dev libxslt1.1 libxslt1-dev  python-lxml
time ./install_pymavlink # new version required for apweb #1m

# Uncomment if AP Web is needed
# tput setaf 3
# echo "Setting up APWeb"
# tput sgr0
#Fix pymavlink for apweb install
# sudo -u $NORMAL_USER -H bash <<EOF
#  set -e
#  set -x

#  pushd /home/$NORMAL_USER/GitHub/pymavlink
#  git config --global user.email "devel@ardupilot.org"
#  git config --global user.name "ArduPilotCompanion"

#  git stash
#  git revert e1532c3fc306d83d03adf82fb559f1bb50860c03
#  export MDEF=~/GitHub/mavlink/message_definitions
#  python setup.py build install --user --force
#  popd
# EOF

# time ./install_apweb # 2m

tput setaf 3
echo "Setting up WiFi AP"
tput sgr0
time sudo -E ./3_wifi_access_point.sh # 20s

tput setaf 3
echo "Creating swap file for libRealsense build"
tput sgr0

time ./create_swap_file.sh

tput setaf 2
echo "Finished installing APSync Components"
echo "Rebooting in 5 sec to enable swap file and WiFi AP"
tput sgr0
popd

sleep 5
reboot # ensure swap file was created