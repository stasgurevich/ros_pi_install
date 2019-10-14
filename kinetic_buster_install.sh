#!/bin/bash

# create distro
cd ~/kinetic_ws
rosinstall_generator desktop ros_comm ros_control ros_controllers serial librealsense2 realsense2_camera freenect_launch openni_launch control_msgs usb_cam image_view timed_launch web_video_server tf2_sensor_msgs --rosdistro kinetic --deps --wet-only --tar > kinetic-desktop-wet.rosinstall
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
#sudo apt remove libpcl*1.9 --purge -y

cd pcl-pcl-1.8.1/build/
sudo make install -j4
cd ~/kinetic_ws

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
#sudo cp src/librealsense/config/99-realsense-libusb.rules  /etc/udev/rules.d
sed -i 's=global_set_flags()=global_set_flags()\nset(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -latomic")=' src/librealsense2/CMakeLists.txt

# build distro
cd ~/kinetic_ws

rm src/gazebo_ros_pkgs -rf
rm src/ros_controllers/ackermann_steering_controller -rf
sudo src/catkin/bin/catkin_make_isolated --install -DCMAKE_BUILD_TYPE=Release --install-space /opt/ros/kinetic -j2 -DCATKIN_ENABLE_TESTING=0 -DFORCE_LIBUVC=true -DBUILD_EXAMPLES=true


#You will get this error: [ 83%] Built target qt_gui_cpp error /usr/bin/ld: cannot find -l-lpthread
sudo sed -i 's=-l-lpthread=-lpthread=' build_isolated/qt_gui_cpp/sip/qt_gui_cpp_sip/Makefile

sudo src/catkin/bin/catkin_make_isolated --install -DCMAKE_BUILD_TYPE=Release --install-space /opt/ros/kinetic -j2 -DCATKIN_ENABLE_TESTING=0 -DFORCE_LIBUVC=true -DBUILD_EXAMPLES=true


cd ~/kinetic_ws