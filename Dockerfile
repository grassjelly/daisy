ARG USE_ROS_DISTRO=

FROM --platform=$BUILDPLATFORM ros:${USE_ROS_DISTRO}-ros-base as base
SHELL ["/bin/bash", "-c"]

# Add a user name for development
ARG ROS2_WS_CONTAINER_NAME=
ARG USERNAME=ubuntu
ARG UID=1000
ARG GID=1000
ENV HOME=/home/${USERNAME}
ENV ROS2_WS=/home/${USERNAME}/${ROS2_WS_CONTAINER_NAME}

RUN apt-get update && apt-get install -y --no-install-recommends \
        udev \
        sudo \
        python3-pip \
        wget \
        ros-${ROS_DISTRO}-foxglove-bridge \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd --gid ${GID} ${USERNAME} \
    && useradd --uid ${UID} --gid ${GID}  --shell /bin/bash --create-home  -m ${USERNAME} \
    && echo ${USERNAME} ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME} \
    && adduser ${USERNAME} video && adduser ${USERNAME} plugdev && adduser ${USERNAME} sudo
RUN touch ${HOME}/.sudo_as_admin_successful

# Write ENV vars export to .bashrc
RUN cp /root/.bashrc ${HOME}/.bashrc
RUN echo "export USER=${USERNAME}" >> ${HOME}/.bashrc
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> ${HOME}/.bashrc
RUN echo "sleep 0.5" >> ${HOME}/.bashrc
RUN echo "if [[ \"\$(wc -w < ${ROS2_WS}/.last_build_errors)\" == \"0\" ]]; then" >> ${HOME}/.bashrc
RUN echo "    source ${ROS2_WS}/install/setup.bash" >> ${HOME}/.bashrc
RUN echo "fi" >> ${HOME}/.bashrc

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
RUN mkdir -p ${ROS2_WS}/src
COPY src ${ROS2_WS}/src

# Install dependencies  of the packages found in src
WORKDIR ${ROS2_WS}
RUN apt-get update
RUN rosdep update --rosdistro=${ROS_DISTRO}
RUN rosdep install --rosdistro=${ROS_DISTRO} --from-paths src -iry --os=ubuntu:$(lsb_release --codename | cut -f2)

# We're only pre-installing the dependencies and not building within the container
# Let users build it
RUN rm -rf ${ROS2_WS}/src/*

RUN sudo chown -R ${USERNAME}:${USERNAME} $HOME
USER ${USERNAME}
ENTRYPOINT ["/entrypoint.sh"]

FROM nvidia/cuda:11.8.0-runtime-ubuntu22.04 as novnc
# FROM nvidia/opengl:1.0-glvnd-runtime
ARG SOURCEFORGE=https://sourceforge.net/projects
ARG WEBSOCKIFY_VERSION=0.11.0
ARG NOVNC_VERSION=1.4.0

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
        git \
        curl \
        build-essential \
        python-is-python3 \
        python3-pip \
        python3-numpy \
        tigervnc-scraping-server \
        fluxbox\
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://github.com/novnc/noVNC/archive/v${NOVNC_VERSION}.tar.gz | tar -xzf - -C /opt \
    && curl -fsSL https://github.com/novnc/websockify/archive/v${WEBSOCKIFY_VERSION}.tar.gz | tar -xzf - -C /opt \
    && mv /opt/noVNC-${NOVNC_VERSION} /opt/noVNC \
    && chmod -R a+w /opt/noVNC \
    && mv /opt/websockify-${WEBSOCKIFY_VERSION} /opt/websockify \
    && cd /opt/websockify && make \
    && cd /opt/noVNC/utils \
    && ln -s /opt/websockify
RUN ln -s /opt/noVNC/vnc.html /opt/noVNC/index.html

RUN openssl req -new -x509 -days 365 -nodes -out self.pem -keyout /root/vnc.pem -batch

RUN echo "#!/bin/bash" > /root/entrypoint.sh
RUN echo "Xorg :200 &" >> /root/entrypoint.sh
RUN echo "exec startfluxbox" >> /root/entrypoint.sh
RUN echo "x0vncserver :200 -localhost no -fg -Geometry 1920x1080 -rfbport 6100 -SecurityTypes None --I-KNOW-THIS-IS-INSECURE &" >> /root/entrypoint.sh
RUN echo "/opt/noVNC/utils/novnc_proxy --vnc localhost:6100 --cert /root/vnc.pem --listen 40001" >> /root/entrypoint.sh
RUN chmod +x /root/entrypoint.sh
ENTRYPOINT ["/root/entrypoint.sh"]
