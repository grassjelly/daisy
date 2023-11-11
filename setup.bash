SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SCRIPT_DIR=$(dirname $SCRIPT_DIR)
export DOCKER_FILES_PATH="$SCRIPT_DIR/daisy/custom"
export ROS2_WS_MOUNT="$SCRIPT_DIR"
export ROS2_WS_CONTAINER_NAME="$(basename $ROS2_WS_MOUNT)"
export DAISY_PATH=$ROS2_WS_MOUNT/daisy

. $DAISY_PATH/.env

FOXY_UBUNTU=18.04
GALACTIC_UBUNTU=20.04
HUMBLE_UBUNTU=22.04
IRON_UBUNTU=22.04
UBUNTU_VER="${USE_ROS_DISTRO^^}_UBUNTU"
export UBUNTU_VER=${!UBUNTU_VER}

GPU_TRUE="gpu"
GPU_FALSE=""
GPU_=""
GPU_BASE="GPU_${ENABLE_GPU^^}"
export GPU_BASE=${!GPU_BASE}

NVIDIA_RUNTIME_TRUE="nvidia"
NVIDIA_RUNTIME_FALSE=""
DOCKER_RUNTIME="NVIDIA_RUNTIME_${ENABLE_GPU^^}"
export DOCKER_RUNTIME=${!DOCKER_RUNTIME}

export U_ID=$(id -u)
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
