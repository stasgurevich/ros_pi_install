cd ~/kinetic_ws
rosinstall_generator %1 --rosdistro kinetic --deps --wet-only --tar > add.rosinstall
wstool merge -t src add.rosinstall
wstool update -t src -j4
rm blacklisted/gazebo_ros_pkgs -rf
mv src/mv gazebo_ros_pkgs blacklisted/
rm blacklisted/ackermann_steering_controller -rf
mv src/ros_controllers/ackermann_steering_controller/ blacklisted/
sudo ./src/catkin/bin/catkin_make_isolated --install -DCMAKE_BUILD_TYPE=Release --install-space /opt/ros/kinetic -j1 -DCATKIN_ENABLE_TESTING=0 --pkg %1