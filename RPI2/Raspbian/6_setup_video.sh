#!/bin/bash

if [ $(id -u) -ne 0 ]; then
   echo >&2 "Must be run as root"
   exit 1
fi

set -e
set -x

# live video related packages
apt-get install -y gstreamer1.0-alsa gstreamer1.0-plugins-ugly-doc gstreamer1.0-plugins-base-apps libgstreamer1.0-dev gstreamer1.0-tools gstreamer1.0-plugins-good gstreamer1.0-espeak gstreamer1.0-omx gstreamer1.0-nice gstreamer1.0-omx-rpi gstreamer1.0-omx-rpi-config gstreamer1.0-fluendo-mp3 gstreamer1.0-rtsp gstreamer1.0-plugins-bad gstreamer1.0-plugins-base gstreamer1.0-gnonlin-doc gstreamer1.0-clutter gstreamer1.0-pulseaudio gstreamer1.0-pocketsphinx gstreamer1.0-plugins-bad-doc gstreamer1.0-omx-generic gstreamer1.0-x gstreamer1.0-gnonlin gstreamer1.0-vaapi-doc gstreamer1.0-omx-generic-config gstreamer1.0-libav gstreamer1.0-plugins-base-doc gstreamer1.0-plugins-good-doc gstreamer1.0-dvswitch gstreamer1.0-clutter-3.0 gstreamer1.0-vaapi gstreamer1.0-packagekit libgstreamer1.0-0 gstreamer1.0-omx-bellagio-config gstreamer1.0-plugins-ugly gstreamer1.0-doc

# opencv - see http://www.pyimagesearch.com/2015/10/26/how-to-install-opencv-3-on-raspbian-jessie/
apt-get install -y build-essential git cmake pkg-config
apt-get install -y libjpeg-dev libtiff5-dev libjasper-dev libpng12-dev
apt-get install -y libavcodec-dev libavformat-dev libswscale-dev libv4l-dev
apt-get install -y libxvidcore-dev libx264-dev
apt-get install -y libgtk2.0-dev
apt-get install -y libatlas-base-dev gfortran
apt-get install -y python2.7-dev python3-dev

# install OpenCV:
pip install numpy
false && sudo -u pi -H bash <<'EOF'
set -e
set -x

pushd $HOME
mkdir opencv
pushd opencv
# wget -O opencv.zip https://github.com/Itseez/opencv/archive/3.0.0.zip
 unzip opencv.zip
# wget -O opencv_contrib.zip https://github.com/Itseez/opencv_contrib/archive/3.0.0.zip
 unzip -o opencv_contrib.zip
 pushd opencv-3.0.0
  mkdir build
  pushd build
   time cmake -D CMAKE_BUILD_TYPE=RELEASE \
 	-D CMAKE_INSTALL_PREFIX=/usr/local \
 	-D INSTALL_C_EXAMPLES=ON \
 	-D INSTALL_PYTHON_EXAMPLES=ON \
 	-D OPENCV_EXTRA_MODULES_PATH=~/opencv_contrib-3.0.0/modules \
 	-D BUILD_EXAMPLES=ON ..
   make -j4
  popd
 popd
popd

EOF

# pushd ~pi/opencv/opencv-3.0.0/build
#  make install
#  ldconfig
# popd

# picamera (likely already included from opencv)
pip install "picamera[array]"

