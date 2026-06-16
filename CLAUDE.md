# Local Notes

## Running Commands

All project commands (ROS2, colcon, Python, etc.) must be run **inside the Docker container**, not on the host.

Use the `./csh` helper script to run commands in the `dev` container. If the container is not running, `./csh` will start it automatically.

```bash
# Run a command and exit
./csh <command>

# Examples
./csh colcon build
./csh ros2 topic list
./csh python3 src/manipulation_perception/manipulation_perception/my_node.py

# Open an interactive shell
./csh
```

## Accessing Generated Files

If a command produces output files that need to be read on the host, run it from `/home/ros/ros2_ws/src/` inside the container so the files are written into the shared volume and appear under `<proj_root>/`.

```bash
./csh "cd src && ros2 run manipulation_perception test_segmentation"
```

## Path Mapping

| Host | Container |
|------|-----------|
| `<proj_root>/` | `/home/ros/ros2_ws/src/` |

The container's working directory is `/home/ros/ros2_ws` (the ROS2 workspace root). Build artifacts (`build/`, `install/`, `log/`) live in the named Docker volume `ros2_ws` and are not written to the host.

## Building

Run a one-shot colcon build with the `colcon-build` service:

```bash
cd docker && docker compose run --rm colcon-build
```

Or interactively inside the `dev` container:

```bash
./csh colcon build --symlink-install
```
