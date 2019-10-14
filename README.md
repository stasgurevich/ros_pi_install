# ros_pi_install

`ros_pi_install` is a way to install ROS Kinetic on Raspberry Pi4 Raspbian Buster.

You need a Raspberry Pi4 with 2GB or 4GB and SD card >= 32 GB. *Please note that the complete install will take about 18 gigs, so 8GB and 16GB cards will not work.*

Make a bootable SD card with  [clear Raspbian Buster image](https://www.raspberrypi.org/downloads/), connect to WiFi, open the terminal and execute the following:
```
git clone https://github.com/stasgurevich/ros_pi_install.git
cd ros_pi_install
sudo bash -x ./prepare.sh
```

This will update your system and will install Boost 1.58 and PCL 1.8.1 from sources. (takes approx 3 hours)

## ROS Installation

I supposed to make the script to install ROS in a single line, but ros_pi_install.sh is still unfinished. You can paste the following into your terminal to make ROS Kinetic distro and install it from sources:

```
# create distro
cd ~/kinetic_ws
rosinstall_generator desktop ros_comm ros_control ros_controllers serial freenect_launch openni_launch control_msgs usb_cam image_view timed_launch web_video_server tf2_sensor_msgs --rosdistro kinetic --deps --wet-only --tar > kinetic-desktop-wet.rosinstall
wstool init src kinetic-desktop-wet.rosinstall -j8
cd src
git clone https://github.com/AprilRobotics/apriltag_ros.git
git clone https://github.com/AprilRobotics/apriltag.git
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
sed -i 's~  char\* str = PyString_AsString(obj);~  const char* str = PyString_AsString(obj);~' src/opencv3/modules/python/src2/cv2.cpp
sed -i 's= PIX_FMT_RGB24=AV_PIX_FMT_RGB24=' src/usb_cam/src/usb_cam.cpp
sed -i 's=(PIX_FMT_RGB24=(AV_PIX_FMT_RGB24=' src/usb_cam/src/usb_cam.cpp
sed -i 's= PIX_FMT_YUV422P=AV_PIX_FMT_YUV422P=' src/usb_cam/src/usb_cam.cpp
sed -i 's=(PIX_FMT_YUV422P=(AV_PIX_FMT_YUV422P=' src/usb_cam/src/usb_cam.cpp

# build distro
cd ~/kinetic_ws

rm src/gazebo_ros_pkgs -rf
rm src/ros_controllers/ackermann_steering_controller -rf
sudo src/catkin/bin/catkin_make_isolated --install -DCMAKE_BUILD_TYPE=Release --install-space /opt/ros/kinetic -j2 -DCATKIN_ENABLE_TESTING=0 -DFORCE_LIBUVC=true -DBUILD_EXAMPLES=true
```

After about 2 hours of compile you will get this error: `[ 83%] Built target qt_gui_cpp error /usr/bin/ld: cannot find -l-lpthread` so paste the following:

```
# apply this patch and resume build
cd ~/kinetic_ws
sudo sed -i 's=-l-lpthread=-lpthread=' build_isolated/qt_gui_cpp/sip/qt_gui_cpp_sip/Makefile
sudo src/catkin/bin/catkin_make_isolated --install -DCMAKE_BUILD_TYPE=Release --install-space /opt/ros/kinetic -j2 -DCATKIN_ENABLE_TESTING=0 -DFORCE_LIBUVC=true -DBUILD_EXAMPLES=true
```

## What you will get

- ROS Kinetic desktop (core packages + rviz)
- [ROS Control library](http://wiki.ros.org/ros_control) + ros_controllers
- GPIO Serial port pins - support via [ROS serial](http://wiki.ros.org/serial)
- Apriltag 3 fiducial markers detection via [apriltag_ros](http://wiki.ros.org/apriltag_ros)
- Kinect 360 support via [openni_launch](http://wiki.ros.org/openni_launch) and [freenect_launch](http://wiki.ros.org/freenect_launch), tuned to work on RPi (remember to use USB 2 port)
- Pi Camera support via [usb_cam](http://wiki.ros.org/usb_cam)

## Notes

*Takes a lot of time!* This script is created with intention to simplify the ROS installation process. Anyway it takes about 4 hours to download and compile all the components on RPi4. Tested on 4GB version with 16GB SanDisk Extreme SD card. In theory can be built on Pi3 with 1GB of RAM, but probably will take about a day to compile.

ROS distro workspace is located in `~/kinetic_ws`

Boost 1.58 build from sources, not packages. Apt install gives compile errors, so I gave up and build it.

# Quick Check
Before you run any ros* command, source this:
```
source /opt/ros/kinetic/setup.sh
```
Check Kinect 360:
```
roslaunch openni_launch openni.launch
or
roslaunch freenect_launch freenect.launch
```
Check Raspberry Camera + AprilTags:
Launch every command in a separate terminal, print the tag from [https://github.com/AprilRobotics/apriltag-imgs/tree/master/tag36h11] and see the coordinates echo.
```
roslaunch usb_cam usb_cam-test.launch
roslaunch apriltag_ros continuous_detection.launch
rostopic echo /tag_detections
```
Visualize:
```
rosrun rviz rviz
```

## TODO

To add support for RealSense D415 and D435 install the packages from GIT sources (ROS packages downloaded by rosinstall_generator are buggy.
Some patches applied to sources to make them compatible with newer GCC. Dirty way to get things up and running.
TBD maybe these patches could be beneficial for others platforms, but maybe they can break distro on other (older) platforms.

