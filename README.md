# ros_pi_install

`ros_pi_install` is a way to install ROS Kinetic on Raspberry Pi4 Raspbian Buster.

You need a Raspberry Pi4 with 2GB or 4GB and SD card >= 32 GB. *Please note that the complete install will take about 18 gigs, so 8GB and 16GB cards will not work.*

Make a bootable SD card with  [clear Raspbian Buster image](https://www.raspberrypi.org/downloads/), connect to WiFi, open the terminal and execute the following:
```
git clone https://github.com/stasgurevich/ros_pi_install.git
cd ros_pi_install
bash -x prepare.sh
```

This will update your system and will install Boost 1.58 and PCL 1.8.1 from sources. (takes approx 3 hours)



## What you will get

- ROS Kinetic desktop (core packages + rviz)
- [ROS Control library](http://wiki.ros.org/ros_control) + ros_controllers
- GPIO Serial port pins - support via [ROS serial](http://wiki.ros.org/serial)
- Apriltag 3 fiducial markers detection via [apriltag_ros](http://wiki.ros.org/apriltag_ros)
- Kinect 360 support via [openni_launch](http://wiki.ros.org/openni_launch) and [freenect_launch](http://wiki.ros.org/freenect_launch), tuned to work on RPi (remember to use USB 2 port)
- RealSense R200 support, patched to use LIBUVC backend & to support newer GCC (remember to use USB 3 port)
- Pi Camera support via [usb_cam](http://wiki.ros.org/usb_cam)

## Notes

*Takes a lot of time!* This script is created with intention to simplify the ROS installation process. Anyway it takes about 4 hours to download and compile all the components on RPi4. Tested on 4GB version with 16GB SanDisk Extreme SD card. In theory can be built on Pi3 with 1GB of RAM.

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
Check RealSense R200:
```
roslaunch realsense_camera r200_nodelet_default.launch
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

Add support for RealSense D415 and D435. 
Some patches applied to sources to make them compatible with newer GCC. Dirty way to get things up and running.
TBD maybe these patches could be beneficial for others platforms, but maybe they can break distro on other (older) platforms.

