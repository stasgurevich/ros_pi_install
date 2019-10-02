#!/bin/bash

# install as much packages as we can through apt
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

# install PCL 1.8.1 from sources (current apt package depends on Boost 1.62 which makes ros_pcl unusable because of dependency conflict)
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
