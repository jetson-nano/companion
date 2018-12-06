#!/bin/bash

if [ $(id -u) -ne 0 ]; then
   echo >&2 "Must be run as root"
   exit 1
fi

. ../config.env

set -e
set -x

tput setaf 2
echo "Installing Packages python-wstool python-rosdep ninja-build"
tput sgr0

#Root user
apt-get install -y python-wstool python-rosdep ninja-build

#This must be done as regular user!!!! change!!!
sudo -u $NORMAL_USER -H bash <<'EOF'
set -e
set -x

tput setaf 2
echo "Setting up catking workspace"
tput sgr0

pushd $HOME
mkdir -p GoogleCartographer_ws/src
mkdir -p GoogleCartographer_ws/launch

pushd $HOME/GoogleCartographer_ws
#catkin_init_workspace

tput setaf 2
echo "Cloning packages into workspace src folder"
tput sgr0

pushd $HOME/GoogleCartographer_ws/src
git clone https://github.com/Slamtec/rplidar_ros.git
git clone https://github.com/GT-RAIL/robot_pose_publisher.git
popd

tput setaf 2
echo "Setting up Google Cartographer settings"
tput sgr0

pushd $HOME/GoogleCartographer_ws/
wstool init src
wstool merge -t src https://raw.githubusercontent.com/googlecartographer/cartographer_ros/master/cartographer_ros.rosinstall
wstool update -t src

pushd $HOME/GoogleCartographer_ws/src/cartographer/scripts
./install_proto3.sh
popd

tput setaf 2
echo "Running rosdep init and update"
tput sgr0

popd
sudo rosdep init || true   # if error message appears about file already existing, just ignore and continue
sudo rosdep fix-permissions
rosdep update
#rosdep install --from-paths src --ignore-src --rosdistro=${ROS_DISTRO} -y
rosdep install --from-paths src --ignore-src --rosdistro=kinetic -y

tput setaf 2
echo "Modifying robot_pose_publisher.cpp, creating cartographer.launch and cartographer.lua"
tput sgr0

popd
popd

cp robot_pose_publisher.cpp $HOME/GoogleCartographer_ws/src/robot_pose_publisher/src
cp cartographer.launch $HOME/GoogleCartographer_ws/src/cartographer_ros/cartographer_ros/launch
cp cartographer.lua $HOME/GoogleCartographer_ws/src/cartographer_ros/cartographer_ros/configuration_files

tput setaf 2
echo "Adding Ardupilot MAVRos launch file"
tput sgr0

cp ArdupilotMavROS.launch $HOME/GoogleCartographer_ws/launch

tput setaf 2
echo "Building Catking Packages"
tput sgr0

pushd $HOME/GoogleCartographer_ws
time catkin build
echo "source /home/apsync/GoogleCartographer_ws/devel/setup.bash" >> ~/.bashrc
source devel/setup.bash

EOF

tput setaf 2
echo "Successfully installed Google Cartographer and Ardupilot Project"
tput sgr0
