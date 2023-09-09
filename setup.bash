export DOCKER_FILES_PATH="$PWD/daisy/custom"
export ROS2_WS_MOUNT="$PWD"
export ROS2_WS_CONTAINER_NAME="$(basename $ROS2_WS_MOUNT)"
export DAISY_PATH=$ROS2_WS_MOUNT/daisy
. $DAISY_PATH/.env
alias daisy-build="$DAISY_PATH/bin/./build"
alias daisy-exec="$DAISY_PATH/bin/./exec"
alias daisy-shell="$DAISY_PATH/bin/./shell"
alias daisy-stop="$DAISY_PATH/bin/./stop"
alias daisy-gitignore="$DAISY_PATH/bin/./gitignore"
alias daisy-template="$DAISY_PATH/bin/./template"
alias daisy-export="$DAISY_PATH/bin/./export"
unset ROS_DISTRO
