cd /home/pi/kinetic_ws
rosinstall_generator $1 --rosdistro kinetic --deps --wet-only --tar > add.rosinstall
wstool merge -t src add.rosinstall
wstool update -t src -j4
rm src/gazebo_ros_pkgs -rf
rm src/ackermann_steering_controller -rf
sudo ./src/catkin/bin/catkin_make_isolated --install -DCMAKE_BUILD_TYPE=Release --install-space /opt/ros/kinetic -j1 -DCATKIN_ENABLE_TESTING=0 --pkg $1