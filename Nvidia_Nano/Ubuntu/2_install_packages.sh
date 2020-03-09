#!/bin/bash

if [ $(id -u) -ne 0 ]; then
   echo >&2 "Must be run as root"
   exit 1
fi

set -e
set -x

. config.env

tput setaf 3
echo "Installing Packages"
tput sgr0

apt remove modemmanager -y 

# install Jetson-stats package run with 'sudo jtop'
pip install jetson-stats

# install packages common to all
../../Common/Ubuntu/install_packages.sh
