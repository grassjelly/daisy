#!/bin/bash
source /opt/ros/rosdistro/setup.bash

# keep track of any errors from last build 
SOURCE_ERROR=$(source /home/username/workspace/install/setup.bash  2>&1 )
echo $SOURCE_ERROR > /home/username/workspace/.last_build_errors
if [[ $(wc -w < /home/username/workspace/.last_build_errors) == 0 ]]; then
    # source the workspace if no errors
    source /home/username/workspace/install/setup.bash
fi

if [ "$ROS_DISTRO" == "humble" ]; then
    export FASTRTPS_DEFAULT_PROFILES_FILE=/home/username/.shm_off.xml
fi

$@
