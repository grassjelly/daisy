 #!/bin/bash
#useful var:
#rosdistro - equivalent to $ROS_DISTRO
#workspace - ROS2 workspace name

source /opt/ros/rosdistro/setup.bash

 if [ "$ROS_DISTRO" == "humble" ]; then
    cd /root
    #https://github.com/eProsima/Fast-DDS/issues/1698#issuecomment-778039676
    wget -O .shm_off.xml https://raw.githubusercontent.com/eProsima/Fast-DDS/107ea8d64942102696840cd7d3e4cf93fa7a143e/examples/cpp/dds/AdvancedConfigurationExample/shm_off.xml
    echo "export FASTRTPS_DEFAULT_PROFILES_FILE=/root/.shm_off.xml" >> /root/.bashrc
fi
