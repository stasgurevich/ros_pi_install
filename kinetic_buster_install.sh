#!/bin/bash

# install needed components
sudo apt update
sudo apt upgrade
mkdir ~/kinetic_ws
cd ~/kinetic_ws
sudo apt install -y python-rosdep python-rosinstall-generator python-wstool python-rosinstall build-essential cmake libopenni-dev openni-utils libpcl-dev libogre-1.9-dev libblis-pthread-dev libghc-bzlib.dev libassimp-dev guvcview

# kinetic needs boost 1.58, installing via apt is not enough, after many retries, I gave up and installed from sources: 
cd ~/kinetic_ws
mkdir boost
cd boost
wget http://sourceforge.net/projects/boost/files/boost/1.58.0/boost_1_58_0.tar.bz2
tar xvfo boost_1_58_0.tar.bz2
cd boost_1_58_0
./bootstrap.sh
sudo ./b2 install
sudo ./b2 install 

# install Kinect 360 driver for OpenNI
cd ~/kinetic_ws
git clone https://github.com/avin2/SensorKinect.git
cd SensorKinect
git checkout unstable
sed -i 's#-mfloat-abi=softfp##g' Platform/Linux/Build/Common/Platform.Arm
cd Platform/Linux/CreateRedist
./RedistMaker
cd ../Redist/Sensor-Bin-Linux-Arm-v5.1.2.1/
sudo ./install.sh
sudo sed -i 's#;UsbInterface=2#UsbInterface=1#g' /usr/etc/primesense/GlobalDefaultsKinect.ini

# create distro
cd ~/kinetic_ws
rosinstall_generator desktop ros_comm ros_control serial librealsense realsense_camera freenect_launch openni_launch control_msgs usb_cam --rosdistro kinetic --deps --wet-only --tar > kinetic-desktop-wet.rosinstall
wstool init src kinetic-desktop-wet.rosinstall -j8
cd src
git clone https://github.com/AprilRobotics/apriltag_ros.git
git clone https://github.com/AprilRobotics/apriltag.git
cd ..
wstool update -j4 -t src
sudo rosdep init
rosdep update
rosdep install -y --from-paths src --ignore-src --rosdistro kinetic -r --os=debian:buster

# apply patches
cd ~/kinetic_ws
sed -i 's=logWarn=CONSOLE_BRIDGE_logWarn=' src/geometry2/tf2/src/buffer_core.cpp
sed -i 's=logError=CONSOLE_BRIDGE_logError=' src/geometry2/tf2/src/buffer_core.cpp
sudo sed -i 's=-l-lpthread=-lpthread=' build_isolated/qt_gui_cpp/sip/qt_gui_cpp_sip/Makefile
sed -i 's=set(BACKEND RS_USE_V4L2_BACKEND)=set(BACKEND RS_USE_LIBUVC_BACKEND)#set(BACKEND RS_USE_V4L2_BACKEND)=' src/librealsense/CMakeLists.txt
sed -i 's=#include <map>=#include <map>\n\n#include <functional>\n\n=' src/librealsense/src/types.h
sed -i 's~  char\* str = PyString_AsString(obj);~  const char* str = PyString_AsString(obj);~' src/opencv3/modules/python/src2/cv2.cpp
sed -i 's= PIX_FMT_RGB24=AV_PIX_FMT_RGB24=' src/usb_cam/src/usb_cam.cpp
sed -i 's=(PIX_FMT_RGB24=(AV_PIX_FMT_RGB24=' src/usb_cam/src/usb_cam.cpp
sed -i 's= PIX_FMT_YUV422P=AV_PIX_FMT_YUV422P=' src/usb_cam/src/usb_cam.cpp
sed -i 's=(PIX_FMT_YUV422P=(AV_PIX_FMT_YUV422P=' src/usb_cam/src/usb_cam.cpp

# build distro
cd ~/kinetic_ws
sudo src/catkin/bin/catkin_make_isolated --install -DCMAKE_BUILD_TYPE=Release --install-space /opt/ros/kinetic -j1 -DCATKIN_ENABLE_TESTING=0




cd ~/kinetic_ws