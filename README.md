# ros_pi_install

`ros_pi_install` is a single-liner to install ROS Kinetic on Raspberry Pi4 Raspbian Buster.

Make a bootable SD card with  [clear Raspbian Buster image](https://www.raspberrypi.org/downloads/), connect to WiFi, then execute the following:
```
curl https://raw.githubusercontent.com/stasgurevich/ros_pi_install/master/kinetic_buster_install.sh | bash -s
```
in your terminal. 

## What you will get

- ROS Kinetic desktop (core components + rviz)
- [ROS Control library](http://wiki.ros.org/ros_control)
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
roslaunch usb_cam usb_cam.launch
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

