ARG USE_ROS_DISTRO=

FROM --platform=$BUILDPLATFORM ros:${USE_ROS_DISTRO}-ros-base as base
SHELL ["/bin/bash", "-c"]

# Add a user name for development
ARG USERNAME=ubuntu
ARG UID=1000
ARG GID=${UID}
RUN groupadd --gid $GID ${USERNAME} && \ 
    useradd --uid ${GID} --gid ${UID} --shell /bin/bash --create-home ${USERNAME} && \
    echo ${USERNAME} ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${USERNAME} && \
    chmod 0440 /etc/sudoers.d/${USERNAME} && \
    mkdir -p /home/${USERNAME} && \
    chown -R ${UID}:${GID} /home/${USERNAME}
RUN echo "export USER=${USERNAME}" >> /home/${USERNAME}/.bashrc

RUN apt-get update -q
RUN apt-get install -y ros-${ROS_DISTRO}-rviz2 python3-pip wget

# Write ENV vars export to .bashrc
ARG ROS2_WS_CONTAINER_NAME=
RUN echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> /home/${USERNAME}/.bashrc
RUN echo "if [ -f /home/${USERNAME}/$ROS2_WS_CONTAINER_NAME/install/setup.bash ]; then" >> /home/${USERNAME}/.bashrc
RUN echo "    source /home/${USERNAME}/$ROS2_WS_CONTAINER_NAME/install/setup.bash" >> /home/${USERNAME}/.bashrc
RUN echo "fi" >> /home/${USERNAME}/.bashrc

# Set workspace name and ROS_DISTRO on entrypoint
COPY daisy/entrypoint.sh /
RUN sed -i "s/rosdistro/${ROS_DISTRO}/" /entrypoint.sh
RUN sed -i "s/workspace/${ROS2_WS_CONTAINER_NAME}/" /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Install Distro specific components
COPY daisy/custom_distro_install.sh /home/${USERNAME}
RUN sed -i "s/rosdistro/${ROS_DISTRO}/" /home/${USERNAME}/custom_distro_install.sh
RUN sed -i "s/workspace/${ROS2_WS_CONTAINER_NAME}/" /home/${USERNAME}/custom_distro_install.sh
RUN chmod +x /home/${USERNAME}/custom_distro_install.sh
RUN /home/${USERNAME}/custom_distro_install.sh

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

USER ${USERNAME}

ENTRYPOINT ["/entrypoint.sh"]
