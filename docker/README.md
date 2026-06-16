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

## Profiles

Docker Compose profiles let you group optional services so they only start when explicitly requested. This keeps the default `./csh` workflow lean — only the `dev` container runs — while still making it easy to bring up extras like a VNC server, a simulation environment, or a GPU debugger on demand.

**Adding a profile to a service**

Open `docker/docker-compose.yaml` and add a `profiles` key to any service you want to make optional:

```yaml
services:
  kasmvnc:
    container_name: kasmvnc
    image: lsiobase/kasmvnc:alpine321
    profiles: [gui]          # only starts when the "gui" profile is active
    network_mode: host
    ...
```

A service without a `profiles` key is always started (the default behaviour); a service with one is skipped unless its profile is activated.

**Starting services in a profile**

```bash
# Start dev + all services tagged "gui"
cd docker && docker compose --profile gui up -d

# Run a one-shot command with a profile active
docker compose --profile gui run --rm kasmvnc
```

You can activate multiple profiles at once:

```bash
docker compose --profile gui --profile sim up -d
```

Or set the `COMPOSE_PROFILES` variable in `docker/.env` to make a profile permanent for your local setup:

```bash
COMPOSE_PROFILES=gui
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
