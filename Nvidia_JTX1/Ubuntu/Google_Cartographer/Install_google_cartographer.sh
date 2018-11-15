#!/bin/bash

if [ $(id -u) -ne 0 ]; then
   echo >&2 "Must be run as root"
   exit 1
fi

set -e
set -x

#Root user
apt-get install python-wstool python-rosdep ninja-build

#This must be done as regular user!!!! change!!!

pushd $HOME
mkdir -p GoogleCartographer_ws/src

pushd $HOME/GoogleCartographer_ws/src
git clone https://github.com/Slamtec/rplidar_ros.git



wstool init src
wstool merge -t src https://raw.githubusercontent.com/googlecartographer/cartographer_ros/master/cartographer_ros.rosinstall
wstool update -t src

pushd cartographer/scripts/
./install_proto3.sh

sudo rosdep init   # if error message appears about file already existing, just ignore and continue
rosdep update
rosdep install --from-paths src --ignore-src --rosdistro=${ROS_DISTRO} -y

popd
git clone https://github.com/GT-RAIL/robot_pose_publisher.git

