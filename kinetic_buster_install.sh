#!/bin/bash

# install needed components
sudo apt update
sudo apt upgrade
mkdir ~/kinetic_ws
cd ~/kinetic_ws
sudo apt install -y python-rosdep python-rosinstall-generator python-wstool python-rosinstall build-essential cmake libopenni-dev openni-utils libogre-1.9-dev libblis-pthread-dev libghc-bzlib.dev libglfw3-dev  libassimp-dev guvcview gedit
sudo pip install -U catkin_tools


# kinetic needs boost 1.58, installing via apt is not enough, after many retries, I gave up and installed from sources: 
cd ~/kinetic_ws
mkdir boost
cd boost
wget http://sourceforge.net/projects/boost/files/boost/1.58.0/boost_1_58_0.tar.bz2
tar xvfo boost_1_58_0.tar.bz2
cd boost_1_58_0
./bootstrap.sh
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

# install PCL 1.8.1 from sources (current apt package depends on Boost 1.62 which makes ros_pcl unusable)
wget https://github.com/PointCloudLibrary/pcl/archive/pcl-1.8.1.tar.gz
tar -xzf pcl-1.8.1.tar.gz
cd pcl-pcl-1.8.1
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
sed -i 's=return (plane_coeff_d_);=return ((std::vector<float>\&)plane_coeff_d_);=' ../segmentation/include/pcl/segmentation/ground_plane_comparator.h
sed -i 's=return (plane_coeff_d_);=return ((std::vector<float>\&)plane_coeff_d_);=' ../segmentation/include/pcl/segmentation/plane_coefficient_comparator.h
# -j2 works on Pi4 4GB -j4 doesn't
make -j2
sudo make install  


# create distro
cd ~/kinetic_ws
rosinstall_generator desktop ros_comm ros_control ros_controllers serial librealsense realsense_camera freenect_launch openni_launch control_msgs usb_cam image_view timed_launch web_video_server tf2_sensor_msgs --rosdistro kinetic --deps --wet-only --tar > kinetic-desktop-wet.rosinstall
wstool init src kinetic-desktop-wet.rosinstall -j8
cd src
git clone https://github.com/AprilRobotics/apriltag_ros.git
git clone https://github.com/AprilRobotics/apriltag.git
git clone https://github.com/MoriKen254/timed_roslaunch.git
cd ..
wstool update -j4 -t src
sudo rosdep init
rosdep update
rosdep install -y --from-paths src --ignore-src --rosdistro kinetic -r --os=debian:buster

# apply patches
cd ~/kinetic_ws
sed -i 's=logWarn=CONSOLE_BRIDGE_logWarn=' src/geometry2/tf2/src/buffer_core.cpp
sed -i 's=logError=CONSOLE_BRIDGE_logError=' src/geometry2/tf2/src/buffer_core.cpp
sed -i 's=set(BACKEND RS_USE_V4L2_BACKEND)=set(BACKEND RS_USE_LIBUVC_BACKEND)#set(BACKEND RS_USE_V4L2_BACKEND)=' src/librealsense/CMakeLists.txt
sed -i 's=#include <map>=#include <map>\n\n#include <functional>\n\n=' src/librealsense/src/types.h
sed -i 's~  char\* str = PyString_AsString(obj);~  const char* str = PyString_AsString(obj);~' src/opencv3/modules/python/src2/cv2.cpp
sed -i 's= PIX_FMT_RGB24=AV_PIX_FMT_RGB24=' src/usb_cam/src/usb_cam.cpp
sed -i 's=(PIX_FMT_RGB24=(AV_PIX_FMT_RGB24=' src/usb_cam/src/usb_cam.cpp
sed -i 's= PIX_FMT_YUV422P=AV_PIX_FMT_YUV422P=' src/usb_cam/src/usb_cam.cpp
sed -i 's=(PIX_FMT_YUV422P=(AV_PIX_FMT_YUV422P=' src/usb_cam/src/usb_cam.cpp
sudo cp src/librealsense/config/99-realsense-libusb.rules  /etc/udev/rules.d

# build distro
cd ~/kinetic_ws
mkdir blacklisted

mv src/mv gazebo_ros_pkgs blacklisted/
mv src/ros_controllers/ackermann_steering_controller/ blacklisted/
sudo src/catkin/bin/catkin_make_isolated --install -DCMAKE_BUILD_TYPE=Release --install-space /opt/ros/kinetic -j1 -DCATKIN_ENABLE_TESTING=0

#[ 83%] Built target qt_gui_cpp error /usr/bin/ld: cannot find -l-lpthread
sudo sed -i 's=-l-lpthread=-lpthread=' build_isolated/qt_gui_cpp/sip/qt_gui_cpp_sip/Makefile




cd ~/kinetic_ws