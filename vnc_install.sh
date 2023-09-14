#!/bin/bash
set -e

USER=$1
HOME=/home/$USER

if [[ "$2" == "false" || "$2" == "false" ]]; then
    exit 0
fi

git clone https://github.com/AtsushiSaito/noVNC.git -b add_clipboard_support /usr/lib/novnc
apt-get install -y tigervnc-standalone-server tigervnc-common lxde-core
pip install git+https://github.com/novnc/websockify.git@v0.10.0
ln -s /usr/lib/novnc/vnc.html /usr/lib/novnc/index.html

# VNC password
VNC_PASSWORD=${PASSWORD:-ubuntu}

mkdir -p $HOME/.vnc
echo $VNC_PASSWORD | vncpasswd -f > $HOME/.vnc/passwd
chmod 600 $HOME/.vnc/passwd
chown -R $USER:$USER $HOME
sed -i "s/password = WebUtil.getConfigVar('password');/password = '$VNC_PASSWORD'/" /usr/lib/novnc/app/ui.js

# xstartup
XSTARTUP_PATH=$HOME/.vnc/xstartup
cat << EOF > $XSTARTUP_PATH
#!/bin/sh
unset DBUS_SESSION_BUS_ADDRESS
/usr/bin/startlxde &
EOF
chown $USER:$USER $XSTARTUP_PATH
chmod 755 $XSTARTUP_PATH

# vncserver launch
VNCRUN_PATH=$HOME/.vnc/vnc_run.sh
cat << EOF > $VNCRUN_PATH
#!/bin/sh

if [ $(uname -m) = "aarch64" ]; then
    LD_PRELOAD=/lib/aarch64-linux-gnu/libgcc_s.so.1 vncserver :1 -fg -geometry 1920x1080 -depth 24
else
    vncserver :1 -fg -geometry 1920x1080 -depth 24
fi
EOF

# Supervisor
# CONF_PATH=/etc/supervisor/conf.d/supervisord.conf
# cat << EOF > $CONF_PATH
# [supervisord]
# nodaemon=true
# user=root
# [program:vnc]
# command=gosu "$USER" bash "$VNCRUN_PATH"
# [program:novonc]
# command=gosu "$USER" bash -c "websockify --web=/usr/lib/novnc 80 localhost:5901
# EOF

