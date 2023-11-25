ARG USE_ROS_DISTRO=
ARG UBUNTU_VER=
ARG RUNTIME=

FROM --platform=$BUILDPLATFORM ros:${USE_ROS_DISTRO}-ros-base as ros2

FROM nvidia/opengl:1.0-glvnd-runtime-ubuntu${UBUNTU_VER} as ros2nvidia
SHELL ["/bin/bash", "-c"]
ENV DEBIAN_FRONTEND=noninteractive

# Install language
RUN apt-get update && apt-get install -y \
        locales \
        && locale-gen en_US.UTF-8 \
        && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*
ENV LANG en_US.UTF-8

# Install timezone
RUN ln -fs /usr/share/zoneinfo/UTC /etc/localtime \
        && export DEBIAN_FRONTEND=noninteractive \
        && apt-get update \
        && apt-get install -y tzdata \
        && dpkg-reconfigure --frontend noninteractive tzdata \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get -y upgrade \
    && rm -rf /var/lib/apt/lists/*

# Install common programs
RUN apt-get update && apt-get install -y --no-install-recommends \
        curl \
        gnupg2 \
        lsb-release \
        sudo \
        software-properties-common \
        wget \
        libegl1-mesa libglu1-mesa libxv1 libxtst6 \
    && rm -rf /var/lib/apt/lists/*

ARG VIRTUALGL_VER="3.1"
RUN wget -O /tmp/virtualgl.deb https://zenlayer.dl.sourceforge.net/project/virtualgl/${VIRTUALGL_VER}/virtualgl_${VIRTUALGL_VER}_amd64.deb
RUN dpkg -i /tmp/virtualgl.deb 

# Install ROS2
ARG USE_ROS_DISTRO=
RUN sudo add-apt-repository universe \
        && curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg \
        && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null \
        && apt-get update && apt-get install -y --no-install-recommends \
            ros-${USE_ROS_DISTRO}-ros-base \
            python3-argcomplete \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y --no-install-recommends \
        ros-dev-tools \
        ros-humble-ament-* \
    && rm -rf /var/lib/apt/lists/*

RUN source /opt/ros/${USE_ROS_DISTRO}/setup.bash
RUN rosdep init 
ENV ROS_DISTRO=${USE_ROS_DISTRO}

FROM ros2${RUNTIME} as workspace
SHELL ["/bin/bash", "-c"]

# Add a user name for development
ARG ROS2_WS_CONTAINER_NAME=
ARG USERNAME=daisy
ARG U_ID=${U_ID}
ENV G_ID=${U_ID}
ENV HOME=/home/${USERNAME}
ENV ROS2_WS=/home/${USERNAME}/${ROS2_WS_CONTAINER_NAME}

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    udev \
    sudo \
    python3-pip \
    wget 

RUN groupadd --gid ${G_ID} ${USERNAME}\
    && useradd -l --uid ${U_ID} --gid ${G_ID} --shell /bin/bash --create-home  -m ${USERNAME} \
    && echo ${USERNAME} ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME} \
    && adduser ${USERNAME} video && adduser ${USERNAME} plugdev && adduser ${USERNAME} sudo
RUN touch ${HOME}/.sudo_as_admin_successful

# Write ENV vars export to .bashrc
RUN cp /root/.bashrc ${HOME}/.bashrc
RUN echo "export USER=${USERNAME}" >> ${HOME}/.bashrc
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> ${HOME}/.bashrc
RUN echo "sleep 0.5" >> ${HOME}/.bashrc
RUN echo "if [[ \"\$(wc -w < ${ROS2_WS}/.last_build_errors)\" == \"0\" && -d \"${ROS2_WS}/install\" ]]; then" >> ${HOME}/.bashrc
RUN echo "    source ${ROS2_WS}/install/setup.bash" >> ${HOME}/.bashrc
RUN echo "fi" >> ${HOME}/.bashrc

# Set workspace name and ROS_DISTRO on entrypoint
COPY daisy/entrypoint.sh /
RUN sed -i "s/rosdistro/${ROS_DISTRO}/g" /entrypoint.sh
RUN sed -i "s/workspace/${ROS2_WS_CONTAINER_NAME}/g" /entrypoint.sh
RUN sed -i "s/username/${USERNAME}/g" /entrypoint.sh
ARG RUNTIME=
RUN if [ ${RUNTIME} == "nvidia" ]; then \
        sed -i 's/\$\@/vglrun +v -d \/dev\/dri\/card0 \$@/' /entrypoint.sh; \
    fi
RUN chmod +x /entrypoint.sh

# Install Distro specific components
RUN if [ "${ROS_DISTRO}" == "humble" ]; then \
        #https://github.com/eProsima/Fast-DDS/issues/1698#issuecomment-778039676
        wget -O /.shm_off.xml https://raw.githubusercontent.com/eProsima/Fast-DDS/107ea8d64942102696840cd7d3e4cf93fa7a143e/examples/cpp/dds/AdvancedConfigurationExample/shm_off.xml; \
        sed -i '''s/<participant profile_name="no_shm_participant_profile">/<participant profile_name="no_shm_participant_profile" is_default_profile="true">/''' /.shm_off.xml; \
        echo "export FASTRTPS_DEFAULT_PROFILES_FILE=/.shm_off.xml" >> /home/${USERNAME}/.bashrc; \
    fi

# Copy the source files so we could find its dependencies 
RUN mkdir -p ${ROS2_WS}/src
COPY src ${ROS2_WS}/src

# Install dependencies  of the packages found in src
WORKDIR ${ROS2_WS}
RUN apt-get update \
        && rosdep update --rosdistro=${ROS_DISTRO} \
        && rosdep install --rosdistro=${ROS_DISTRO} --from-paths src -iry --os=ubuntu:$(lsb_release --codename | cut -f2) \
    && rm -rf /var/lib/apt/lists/*

# We're only pre-installing the dependencies and not building within the container
# Let users build it
RUN rm -rf ${ROS2_WS}/src/*
RUN mkdir -p ${HOME}/maps
RUN chown -R ${U_ID}:${G_ID} ${HOME}
ARG USERNAME=daisy
USER ${USERNAME}

FROM workspace as base
## ADD custom install here

ENTRYPOINT ["/entrypoint.sh"]
