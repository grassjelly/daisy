export DOCKER_FILES_PATH="$PWD/daisy/custom"
export ROS2_WS_MOUNT="$PWD"
export ROS2_WS_CONTAINER_NAME="$(basename $ROS2_WS_MOUNT)"
export DAISY_PATH=$ROS2_WS_MOUNT/daisy
. $DAISY_PATH/.env
alias daisy-build="$DAISY_PATH/./build"
alias daisy-exec="$DAISY_PATH/./exec"
alias daisy-shell="$DAISY_PATH/./shell"
alias daisy-stop="$DAISY_PATH/./stop"
alias daisy-gitignore="$DAISY_PATH/./gitignore"
alias daisy-template="$DAISY_PATH/./template"
unset ROS_DISTRO
