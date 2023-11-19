ARG USE_ROS_DISTRO=

FROM --platform=$BUILDPLATFORM ros:${USE_ROS_DISTRO}-ros-base as base
SHELL ["/bin/bash", "-c"]

RUN apt-get update -q
RUN apt-get install -y ros-${ROS_DISTRO}-rviz2 python3-pip wget

# Write ENV vars export to .bashrc
ARG ROS2_WS_CONTAINER_NAME=
RUN echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> /root/.bashrc
RUN echo "if [ -f /root/$ROS2_WS_CONTAINER_NAME/install/setup.bash ]; then" >> /root/.bashrc
RUN echo "    source /root/$ROS2_WS_CONTAINER_NAME/install/setup.bash" >> /root/.bashrc
RUN echo "fi" >> /root/.bashrc

# Set workspace name and ROS_DISTRO on entrypoint
COPY docker/entrypoint.sh /root
RUN sed -i "s/rosdistro/${ROS_DISTRO}/" /root/entrypoint.sh
RUN sed -i "s/workspace/${ROS2_WS_CONTAINER_NAME}/" /root/entrypoint.sh
RUN chmod +x /root/entrypoint.sh

# Install custom specific add-ons
RUN if [ "${ROS_DISTRO}" == "humble" ]; then \
        #https://github.com/eProsima/Fast-DDS/issues/1698#issuecomment-778039676
        wget -O /.shm_off.xml https://raw.githubusercontent.com/eProsima/Fast-DDS/107ea8d64942102696840cd7d3e4cf93fa7a143e/examples/cpp/dds/AdvancedConfigurationExample/shm_off.xml; \
        sed -i '''s/<participant profile_name="no_shm_participant_profile">/<participant profile_name="no_shm_participant_profile" is_default_profile="true">/''' /.shm_off.xml; \
        echo "export FASTRTPS_DEFAULT_PROFILES_FILE=/.shm_off.xml" >> /root/.bashrc; \
    fi

RUN mkdir -p /root/${ROS2_WS_CONTAINER_NAME}/src/${PACKAGE_NAME}
COPY . /root/${ROS2_WS_CONTAINER_NAME}/src/${PACKAGE_NAME}

WORKDIR /root/${ROS2_WS_CONTAINER_NAME}
RUN rosdep update --rosdistro=${ROS_DISTRO}
RUN rosdep install --rosdistro=${ROS_DISTRO} --from-paths src -iry --os=ubuntu:$(lsb_release --codename | cut -f2)
RUN source /opt/ros/$ROS_DISTRO/setup.bash && \
    colcon build

ENTRYPOINT ["/root/entrypoint.sh"]
