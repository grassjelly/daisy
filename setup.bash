SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SCRIPT_DIR=$(dirname $SCRIPT_DIR)
export DOCKER_FILES_PATH="$SCRIPT_DIR/daisy/custom"
export ROS2_WS_MOUNT="$SCRIPT_DIR"
export ROS2_WS_CONTAINER_NAME="$(basename $ROS2_WS_MOUNT)"
export DAISY_PATH=$ROS2_WS_MOUNT/daisy
export U_ID=$(id -u)
if [ -d "/sys/module/nvidia" ]; then
    export NVIDIA_DRIVER=$(cat /sys/module/nvidia/version)
fi
. $DAISY_PATH/.env
alias daisy-build="$DAISY_PATH/bin/./build"
alias daisy-exec="$DAISY_PATH/bin/./exec"
alias daisy-compose="$DAISY_PATH/bin/./compose"
alias daisy-shell="$DAISY_PATH/bin/./shell"
alias daisy-stop="$DAISY_PATH/bin/./stop"
alias daisy-gitignore="$DAISY_PATH/bin/./gitignore"
alias daisy-template="$DAISY_PATH/bin/./template"
alias daisy-export="$DAISY_PATH/bin/./export"
alias daisy-tmux="$DAISY_PATH/bin/./tmux"
unset ROS_DISTRO
