## Prerequisites

### gazebo-cuda build

The `gazebo-cuda` base image requires Docker with NVIDIA container runtime support.

**1. Install Docker and NVIDIA container runtime**

```bash
sudo apt update && sudo apt install -y curl

curl -sSL https://get.docker.com | sudo sh
sudo usermod -aG docker $USER
sudo systemctl restart docker
```

If an NVIDIA GPU is present, install the NVIDIA container toolkit:

```bash
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey \
  | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg

curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list \
  | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' \
  | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

sudo apt update && sudo apt install -y nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker --set-as-default
sudo systemctl daemon-reload && sudo systemctl restart docker
```

**2. Install NVIDIA drivers**

```bash
sudo apt update && sudo apt install -y ubuntu-drivers-common
sudo ubuntu-drivers autoinstall
```

Reboot after driver installation before building the image.

## Usage

**1. Configure the project**

Edit `docker/.env` to set your project name and desired base image:

```bash
PROJECT_NAME=my_project
BASE_IMAGE=gazebo-cuda   # hardware | gazebo | gazebo-cuda
```


**2. Add your ROS 2 packages**

Place your ROS 2 package directories directly inside the project root. They are picked up via the volume mount in the `dev` container.

**3. Build the Docker image**

```bash
cd docker && ./build
```

**4. Start developing**

From the project root, use `csh` to run commands inside the `dev` container (it starts the container automatically if not running):

```bash
# Open an interactive shell
./csh

# Run a single command
./csh colcon build --symlink-install
./csh ros2 topic list
```

## Customization

- Edit `docker/.env` to change the ROS distro, base image variant, domain ID, or GPU.
- Edit `docker/docker-compose.yaml` to add or modify services.
- Edit `docker/Dockerfile` to install additional system dependencies.

## Configuration Reference

### Image naming

The Docker image is tagged as `<PROJECT_NAME>:<BASE_IMAGE>`. With the defaults the image is:

```
ros2_docker_ws:gazebo-cuda
```

### Workspace name

The ROS workspace inside the container is `/home/ros/<WORKSPACE_NAME>`. The default is `ros2_ws`, giving `/home/ros/ros2_ws`.

| Host (project root) | Container |
|---------------------|-----------|
| `./`                | `/home/ros/ros2_ws/src/` |

Build artifacts (`build/`, `install/`, `log/`) live in the named Docker volume `<PROJECT_NAME>_ros2_ws` and are not written to the host.
