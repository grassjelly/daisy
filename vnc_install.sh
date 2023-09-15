#!/bin/bash
#SOURCE https://github.com/Tiryoh/docker-ros2-desktop-vnc
set -e

USER=$1
HOME=/home/$USER

if [[ "$2" == "false" || "$2" == "false" ]]; then
    exit 0
fi

git clone https://github.com/AtsushiSaito/noVNC.git -b add_clipboard_support $HOME/novnc
sed -i "s/UI.initSetting('resize', 'off');/UI.initSetting('resize', 'remote');/g" $HOME/novnc/app/ui.js
DEBIAN_FRONTEND=noninteractive apt-get install -y tigervnc-standalone-server tigervnc-common lxde-core
pip install git+https://github.com/novnc/websockify.git@v0.10.0
ln -s $HOME/novnc/vnc.html $HOME/novnc/index.html

# VNC password
VNC_PASSWORD=${PASSWORD:-ubuntu}

mkdir -p $HOME/.vnc
echo $VNC_PASSWORD | vncpasswd -f > $HOME/.vnc/passwd
chmod 600 $HOME/.vnc/passwd
chown -R $USER:$USER $HOME
sed -i "s/password = WebUtil.getConfigVar('password');/password = '$VNC_PASSWORD'/" $HOME/novnc/app/ui.js

# xstartup
XSTARTUP_PATH=$HOME/.vnc/xstartup
cat << EOF > $XSTARTUP_PATH
#!/bin/sh
unset DBUS_SESSION_BUS_ADDRESS
/usr/bin/startlxde
EOF
chown $USER:$USER $XSTARTUP_PATH
chmod 755 $XSTARTUP_PATH

# vncserver launch
VNCRUN_PATH=$HOME/.vnc/vnc_run.sh
cat << EOF > $VNCRUN_PATH
#!/bin/sh

rm -f /tmp/.X200-lock
rm -f /tmp/.X11-unix/X200

if [ $(uname -m) = "aarch64" ]; then
    LD_PRELOAD=/lib/aarch64-linux-gnu/libgcc_s.so.1 vncserver :200 -fg -geometry 1920x1080 -depth 24
else
    vncserver :200 -fg -geometry 1920x1080 -depth 24
fi
EOF

sed -i "`wc -l < /entrypoint.sh`i\\bash $HOME/.vnc/vnc_run.sh &\\" /entrypoint.sh
sed -i "`wc -l < /entrypoint.sh`i\\sudo websockify --web=$HOME/novnc/ 90 localhost:6100 &\\" /entrypoint.sh