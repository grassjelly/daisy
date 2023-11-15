export DAISY_PATH="$(cd $(dirname $BASH_SOURCE) ; pwd -P )"
export ROS2_WS_MOUNT="$(dirname $DAISY_PATH)"
export ROS2_WS_CONTAINER_NAME="$(basename $ROS2_WS_MOUNT)"

. $DAISY_PATH/.env

FOXY_UBUNTU=18.04
GALACTIC_UBUNTU=20.04
HUMBLE_UBUNTU=22.04
IRON_UBUNTU=22.04
UBUNTU_VER="${USE_ROS_DISTRO^^}_UBUNTU"
export UBUNTU_VER=${!UBUNTU_VER}

export U_ID=$(id -u)
alias daisy-build="$DAISY_PATH/bin/./build"
alias daisy-compose="$DAISY_PATH/bin/./compose"
alias daisy-export="$DAISY_PATH/bin/./export"
alias daisy-gitignore="$DAISY_PATH/bin/./gitignore"
alias daisy-shell="$DAISY_PATH/bin/./shell"
alias daisy-template="$DAISY_PATH/bin/./template"
alias daisy-tmux="$DAISY_PATH/bin/./tmux"
unset ROS_DISTRO
