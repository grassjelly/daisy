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
COPY daisy/entrypoint.sh /root
RUN sed -i "s/rosdistro/${ROS_DISTRO}/" /root/entrypoint.sh
RUN sed -i "s/workspace/${ROS2_WS_CONTAINER_NAME}/" /root/entrypoint.sh
RUN chmod +x /root/entrypoint.sh

# Install custom specific add-ons
COPY daisy/custom_distro_install.sh /root
RUN sed -i "s/rosdistro/${ROS_DISTRO}/" /root/custom_distro_install.sh
RUN sed -i "s/workspace/${ROS2_WS_CONTAINER_NAME}/" /root/custom_distro_install.sh
RUN chmod +x /root/custom_distro_install.sh
RUN /root/custom_distro_install.sh

RUN mkdir -p /root/${ROS2_WS_CONTAINER_NAME}/src
COPY src /root/${ROS2_WS_CONTAINER_NAME}/src

WORKDIR /root/${ROS2_WS_CONTAINER_NAME}
RUN rosdep update --rosdistro=${ROS_DISTRO}
RUN rosdep install --rosdistro=${ROS_DISTRO} --from-paths src -iry --os=ubuntu:$(lsb_release --codename | cut -f2)

RUN rm -rf /root/${ROS2_WS_CONTAINER_NAME}/src/*

ENTRYPOINT ["/root/entrypoint.sh"]
