#!/bin/bash
source /opt/ros/rosdistro/setup.bash

if [ -f /root/workspace/install/setup.bash ]; then
    source /root/workspace/install/setup.bash
fi

if [ "$ROS_DISTRO" == "humble" ]; then
    export FASTRTPS_DEFAULT_PROFILES_FILE=/root/.shm_off.xml
fi

$@