rosinstall_generator %1 --rosdistro kinetic --deps --wet-only --tar > add.rosinstall
wstool merge -t src add.rosinstall
wstool update -t src -j4
sudo ./src/catkin/bin/catkin_make_isolated --install -DCMAKE_BUILD_TYPE=Release --install-space /opt/ros/kinetic -j1 -DCATKIN_ENABLE_TESTING=0