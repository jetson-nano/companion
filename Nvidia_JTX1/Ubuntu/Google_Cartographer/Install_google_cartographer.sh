#!/bin/bash

if [ $(id -u) -ne 0 ]; then
   echo >&2 "Must be run as root"
   exit 1
fi

. ../config.env

set -e
set -x

#Root user
apt-get install python-wstool python-rosdep ninja-build

#This must be done as regular user!!!! change!!!
sudo -u $NORMAL_USER -H bash <<'EOF'
set -e
set -x

pushd $HOME
mkdir -p GoogleCartographer_ws/src

pushd $HOME/GoogleCartographer_ws/src
git clone https://github.com/Slamtec/rplidar_ros.git


pushd $HOME/GoogleCartographer_ws/
wstool init src
wstool merge -t src https://raw.githubusercontent.com/googlecartographer/cartographer_ros/master/cartographer_ros.rosinstall
wstool update -t src

pushd src/cartographer/scripts/
./install_proto3.sh

popd
sudo rosdep init || true   # if error message appears about file already existing, just ignore and continue
rosdep update
rosdep install --from-paths src --ignore-src --rosdistro=${ROS_DISTRO} -y

pushd $HOME/GoogleCartographer_ws/src
git clone https://github.com/GT-RAIL/robot_pose_publisher.git

EOF
