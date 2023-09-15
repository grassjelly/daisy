ARG USE_ROS_DISTRO=

FROM --platform=$BUILDPLATFORM ros:${USE_ROS_DISTRO}-ros-base as base
SHELL ["/bin/bash", "-c"]

# Add a user name for development
ARG USERNAME=ubuntu
ARG UID=1000
ARG GID=1000

RUN apt-get update && apt-get install -y udev sudo

RUN groupadd --gid ${GID} ${USERNAME} && \
    useradd --uid ${UID} --gid ${GID}  --shell /bin/bash --create-home  -m ${USERNAME} && \
    echo ${USERNAME} ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${USERNAME} && \
    chmod 0440 /etc/sudoers.d/${USERNAME} && \
    adduser ${USERNAME} video && adduser ${USERNAME} plugdev && adduser ${USERNAME} sudo
RUN cp /root/.bashrc /home/${USERNAME}/.bashrc
RUN echo "export USER=${USERNAME}" >> /home/${USERNAME}/.bashrc
RUN mkdir -p /home/${USERNAME}/.ros/log

RUN apt-get install -y ros-${ROS_DISTRO}-rviz2 python3-pip wget

# Write ENV vars export to .bashrc
ARG ROS2_WS_CONTAINER_NAME=
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> /home/${USERNAME}/.bashrc
RUN echo "if [[ -z \$(cat /home/${USERNAME}/${ROS2_WS_CONTAINER_NAME}/.last_build_errors) ]]; then" >> /home/${USERNAME}/.bashrc
RUN echo "    source /home/${USERNAME}/${ROS2_WS_CONTAINER_NAME}/install/setup.bash" >> /home/${USERNAME}/.bashrc
RUN echo "fi" >> /home/${USERNAME}/.bashrc

# Set workspace name and ROS_DISTRO on entrypoint
COPY daisy/entrypoint.sh /
RUN sed -i "s/rosdistro/${ROS_DISTRO}/" /entrypoint.sh
RUN sed -i "s/workspace/${ROS2_WS_CONTAINER_NAME}/" /entrypoint.sh
RUN sed -i "s/username/${USERNAME}/" /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Install Distro specific components
COPY daisy/custom_distro_install.sh /
RUN sed -i "s/rosdistro/${ROS_DISTRO}/" /custom_distro_install.sh
RUN sed -i "s/workspace/${ROS2_WS_CONTAINER_NAME}/" /custom_distro_install.sh
RUN sed -i "s/username/${USERNAME}/" /custom_distro_install.sh
RUN chmod +x /custom_distro_install.sh
RUN /custom_distro_install.sh

# Copy the source files so we could find its dependencies 
RUN mkdir -p /home/${USERNAME}/${ROS2_WS_CONTAINER_NAME}/src
COPY src /home/${USERNAME}/${ROS2_WS_CONTAINER_NAME}/src

# Install dependencies  of the packages found in src
WORKDIR /home/${USERNAME}/${ROS2_WS_CONTAINER_NAME}
RUN rosdep update --rosdistro=${ROS_DISTRO}
RUN rosdep install --rosdistro=${ROS_DISTRO} --from-paths src -iry --os=ubuntu:$(lsb_release --codename | cut -f2)

# We're only pre-installing the dependencies and not building within the container
# Let users build it
RUN rm -rf /home/${USERNAME}/${ROS2_WS_CONTAINER_NAME}/src/*

ARG USE_VNC=false
COPY daisy/vnc_install.sh /
RUN bash /vnc_install.sh ${USERNAME} ${USE_VNC}

ENTRYPOINT ["/entrypoint.sh"]
