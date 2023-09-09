## daisy 
(docker lazy)
A tool to easily run a Docker container inside a ROS2 workspace. 

If you want to quickly test a ROS2 package without system installing ROS2, or simply want to test whether your package builds on another distro, this tool is for you.

### 1. Installation
#### 1.1 Install Docker
```
curl https://get.docker.com | sh && sudo systemctl --now enable docker
```
Post Docker Installation:
```
sudo usermod -aG docker $USER && newgrp docker
```
If you're running with a Nvidia GPU, install [Nvidia Runtime](https://github.com/NVIDIA/nvidia-container-runtime#installation) and [reconfigure](https://github.com/NVIDIA/nvidia-container-runtime#daemon-configuration-file) the deafult runtime.

#### 1.2 Download daisy
Clone daisy into your ROS2 workspace (eg. $HOME/my_ros2_ws):
```
cd $HOME/my_ros2_ws
git clone https://github.com/grassjelly/daisy.git
```

#### 1.3 Build the Docker image:
```
cd $HOME/my_ros2_ws
source daisy/setup.bash
daisy-build <distro>
```
- **distro** can be `foxy`, `galactic`, `humble`, or `iron`

`daisy-build` will automatically find the dependencies of all the the ROS2 packages inside `src` directory of your workspace. **Take note that running this will stop all daisy spawned containers.**

Now you're ready to use the container.

### 2. Usage

#### 2.1 Running a comand from the host machine to the Docker container

For instance building the workspace:
```
cd $HOME/my_ros2_ws
source daisy/setup.bash
daisy-exec colcon build
```
or checking out topics available:
```
cd $HOME/my_ros2_ws
source daisy/setup.bash
daisy-exec ros2 topic list
```

#### 2.2 Shell mode
This mode allows you to run commands within the docker container itself like you're using it natively in your host machine:
```
cd $HOME/my_ros2_ws
source daisy/setup.bash
daisy-shell
```
Once inside the container, you can start using ROS2 commands. For instance:
```
ros2 launch my_package my_launch_file.launch.py
```
#### 2.3 Stopping the container
Once you're done using the container, you can stop it by running:
```
cd $HOME/my_ros2_ws
source daisy/setup.bash
daisy-stop
```

### 3. Dockerizing the workspace or a specific package

#### 3.1 Using git
If you're using git within the workspace, you can use `daisy-gitignore` to add a .gitignore file in your ROS2 workspace to prevent commiting `build` `install` and `log` directories.

Run:
```
cd $HOME/my_ros2_ws
source daisy/setup.bash
daisy-gitignore
```

#### 3.2 Standalone Docker image
If you want to dockerize a specific package, you can use `daisy-template` to create an auto-generate a docker directory in your ROS2 package's root directory that contains all the files to create a Docker image and compose services.

```
cd $HOME/my_ros2_ws
source daisy/setup.bash
daisy-template src/<my_package>
```
- `my_package` is the ROS2 package where you want to deploy the Docker template.

To test:
```
cd $HOME/my_ros2_ws/src/my_package/docker
docker compose build
```

Once done, you can check if it works by running the `test` service to build the workspace:
```
cd $HOME/my_ros2_ws/src/my_package/docker
docker compose up test
```

You can check out this comprehensive [tutorial](https://roboticseabass.com/2023/07/09/updated-guide-docker-and-ros2/) to learn more about ROS2-Docker workflows.