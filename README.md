## 🌼 daisy
(docker lazy)
A tool to easily Dockerize ROS2 workspaces and packages. 

In a nutshell, daisy contains a built-in [`Dockerfile`](./Dockerfile) and [`docker-compose.yaml`](./docker-compose.yaml) files to quickly spin a Docker container for the ROS2 workspace you're working on. It's a thin layer to conveniently call [Docker Compose](https://docs.docker.com/compose/) commands with a few helper scripts.

Daisy aims to make ROS2 development workspaces become more reproducible without the huge bulk of git commiting all the source codes found in the workspace using [vcstool](https://github.com/dirk-thomas/vcstool#export-set-of-repositories).

If you want to quickly test a ROS2 package without system installing ROS2, or simply want to test whether your package builds on another distro, this tool is for you.

A huge thanks to Sebastian Castro for this [blog post](https://roboticseabass.com/2023/07/09/updated-guide-docker-and-ros2/) and [Allison Thackston's Docker files](https://github.com/athackst/dockerfiles) which was used as a main reference in building this tool.

| COMMAND           | ARGUMENTS                    | DESCRIPTION                                             |
|-------------------|------------------------------|---------------------------------------------------------|
| `daisy-build`     |-h                            | Build the workspace's Docker image.                     |
| `daisy-compose`   |<docker_compose_args>         | Similar to docker-compose. But can be run anywhere.     |
| `daisy-shell`     |<bash_commands>               | Run bash commands from host or log-in inside container. |
| `daisy-gitignore` |                              | Add _build_ _install_ _log_ to .gitignore of workspace. |
| `daisy-template`  |src/my_package                | Add docker template to ROS2 package.                    |
| `daisy-export`    |                              | Record all local repositories found in src.             |
| `daisy-tmux`      |<tmux_profile>                | Record all local repositories found in src.             |

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
To use daisy, source the setup.bash file:
```
cd $HOME/my_ros2_ws
source daisy/setup.bash
```
- Once sourced, you can use daisy in any directory.

#### 1.3 Build the Docker image:
```
daisy-build <distro>
```
- **distro** can be `foxy`, `galactic`, `humble`, or `iron`

`daisy-build` will automatically find the dependencies of all the the ROS2 packages inside `src` directory of your workspace. **Take note that running this will stop all daisy spawned containers.**

You'll only need to run this command once or when you have made changes on on the dependencies (package.xml). You can modify the Dockerfile as you wish to add custom installation commands just remember to run `daisy-build` again when you're done. You can use the `--skip-import` flag to skip VCS import on re-builds.

Take note that this does not build your ROS2 workspace. You'll have to build it explicitly by running:
```
daisy-compose up colcon-build
```
### 2. Usage
#### 2.1 Running bash commands relative to the docker-compose.yaml.
Using `daisy-compose`, you can run docker compose commands that are relative to the docker-compose.yaml file. This means you can run `docker compose` commands without being on the same directory as the compose file. For instance:
```
daisy-compose up my_service
```
is similar to:
```
cd /home/my_ros2_ws/daisy #docker-compose.yaml directory
docker compose up my_service
```

#### 2.2 Debugging tool
You can use `daisy-shell`, to spawn a container and run bash commands inside the container from the host. For example:
```
daisy-shell ros2 topic list
```
This will return all the topics available within the network.

If no bash command is provided, it will log-in the debug container and use it like a normal shell.

### 3. Dockerizing ROS2 workspaces and ROS2 packages

#### 3.1 Dockerizing ROS2 workspaces (with src in git)
If you're Dockerizing your ROS2 workspace and pushing it in a git repository with the source codes in src,  use `daisy-gitignore` to add a .gitignore file in your ROS2 workspace to prevent commiting _build_ _install_ and _log_ directories.

Run:
```
daisy-gitignore
```

#### 3.2 Dockerizing ROS2 workspaces (without src in git)
This is a wrapper to [vcs-tool](https://github.com/dirk-thomas/vcstool#export-set-of-repositories) `export` command. If you're Dockerizing your ROS2 workspace and pushing it in a git repository without the source codes in src, use `daisy-export` to record all the local repositories found in your src directory. `daisy-build` will automatically download all the repositories if an install.repos is found on the workspace.

Run:
```
daisy-export
```

This also auto-generates a quickstart guide (README.md) of the workspace.

#### 3.3 Dockerizing ROS2 Packages
`daisy-template` auto-generates a docker directory that contains all the files to create a Docker image and compose services.

```
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
docker compose up test
```

You can check out this comprehensive [tutorial](https://roboticseabass.com/2023/07/09/updated-guide-docker-and-ros2/) to learn more about ROS2-Docker workflows.

#### 3.4 Running multiple screens and services.

`daisy-tmux` is wrapper for [Tmuxinator](https://github.com/tmuxinator/tmuxinator) to spawn multiple screens and services.

##### 3.4.1 Open multiple screens

```
daisy-tmux <number_of_screens>
```

##### 3.4.2 Using profiles

Create a profile in daisy/tmux/my_profile.yaml by defining the docker services you want to run per pane. You can use `template.yaml` as a starting point.
```
daisy-tmux my_profile
```

- daisy-tmux has an autocomplete feature that suggests all the created profiles in daisy/tmux by simply pressing tab after `daisy-tmux` command.

##### 3.4.3 Exiting
On one of the panes, run:
```
daisy-tmux -1
```

### 3. Miscellaneous

#### 3.1 VNC Server and Web Client

There's a built-in KasmVNC server and Web Based client available in the daisy/daisy-compose.yaml. Simply run:

```
daisy-compose up webtop
```

On services that need a screen, `export DISPLAY:=200` to pipe the display to the VNC server.
```
export DISPLAY:=200; daisy-compose up rviz
```

Now, you can view your applications in http://localhost:3000. This has also been tested on a remote setup on a GCP instance with [Tailscale](https://tailscale.com) for secured remote access. The Docker image has been configured to use [VirtualGL](https://virtualgl.org) for 3D acceleration (Nvidia GPUs) while using the VNC server for screen display.
