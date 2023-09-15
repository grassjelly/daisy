#!/bin/bash
source /opt/ros/rosdistro/setup.bash

if [ -f /home/username/workspace/install/setup.bash ]; then
    source /home/username/workspace/install/setup.bash
fi

if [ "$ROS_DISTRO" == "humble" ]; then
    export FASTRTPS_DEFAULT_PROFILES_FILE=/home/username/.shm_off.xml
fi

$@
