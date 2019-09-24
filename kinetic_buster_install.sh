#!/bin/bash
mkdir ~/kinetic_ws
cd ~/kinetic_ws

# install needed components
sudo apt install -y python-rosdep python-rosinstall-generator python-wstool python-rosinstall build-essential cmake libopenni-dev libpcl-dev libogre-1.9-dev libblis-pthread-dev
sudo apt update

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

# install assimp
cd ~/kinetic_ws
mkdir -p ~/kinetic_ws/external_src
cd ~/kinetic_ws/external_src
wget http://sourceforge.net/projects/assimp/files/assimp-3.1/assimp-3.1.1_no_test_models.zip/download -O assimp-3.1.1_no_test_models.zip
unzip assimp-3.1.1_no_test_models.zip
cd assimp-3.1.1
cmake .
make
sudo make install

# create distro
cd ~/kinetic_ws
rosinstall_generator desktop ros_comm ros_control serial librealsense realsense_camera freenect_launch openni_launch control_msgs --rosdistro kinetic --deps --wet-only --tar > kinetic-desktop-wet.rosinstall
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
sed -i 's=-l-lpthread=-lpthread=' build_isolated/qt_gui_cpp/sip/qt_gui_cpp_sip/Makefile
sed -i 's=set(BACKEND RS_USE_V4L2_BACKEND)=set(BACKEND RS_USE_LIBUVC_BACKEND)#set(BACKEND RS_USE_V4L2_BACKEND)=' src/librealsense/CMakeLists.txt

# build distro
cd ~/kinetic_ws
sudo ./src/catkin/bin/catkin_make_isolated --install -DCMAKE_BUILD_TYPE=Release --install-space /opt/ros/kinetic -j1 -DCATKIN_ENABLE_TESTING=0
