# RobBDD, ROS 2, MuJoCo Setup Automation

Script for setting up a ROS 2 workspace linked to a Python virtual environment,
including the BDD coordinator, optionally a MuJoCo behaviour node,
and all required dependencies.

## Setup

```bash
git clone https://github.com/minhnh/bdd-ros-mjc-setup.git
cd bdd-ros-mjc-setup
./setup-bdd-ros-mjc.sh ~/ros_bdd_ws
```

This setup clones and builds (see [`bdd-ros2.repos`](./bdd-ros2.repos)):

- `bdd_exec_ros2`
- `bdd_ros2_interfaces`
- `bdd-dsl`
- `scene-dsl`
- `coord-dsl`
- `robbdd`
- `rdf-utils`

This setup assume ROS2 installed. Additionally, virtual environment setup requires
[`venv`](https://docs.python.org/3/library/venv.html), and source management requires
[vcs2l](https://github.com/ros-infrastructure/vcs2l). `vcs2l` is used to clone dependencies
listed in the [repos file](./bdd-ros2-mjc.repos).

These packages can be installed with `sudo apt install python3-vcs2l python3-venv`.

To update cloned repos, run:

```bash
vcs pull ~/ros_bdd_ws < ./bdd-ros2.repos
```

### Optional: MuJoCo pick & place

Optionally, the script can also install a sample pick & place application using MuJoCo,
which include the following packages (see [`mjc-pickplace.repos`](./mjc-pickplace.repos)):

- `mj_kdl_wrapper`
- `bdd_mjc_pickplace_py`

For this to work, the following dependencies must be installed:

```bash
sudo apt install cmake g++ git python3-dev python3-venv \
  libeigen3-dev libglfw3-dev libgl-dev libegl-dev ffmpeg
```

To trigger this optional installation, add 1 to the above script execution:

```bash
./setup-bdd-ros-mjc.sh ~/ros_bdd_ws 1
```

Executing the script with MuJoCo setup will also fetch MuJoCo menagerie
models used by `mj_kdl_wrapper`.

## Environment activation

In a fresh terminal:

```bash
source ~/ros_bdd_ws/venv/bin/activate
source ~/ros_bdd_ws/install/setup.bash
```

## Run full test execution

Launch the integrated BDD coordinator + MuJoCo behaviour stack:

```bash
ros2 launch bdd_mjc_pickplace_py launch_mjc_pickplace_stack.yaml
```

With GUI:

```bash
ros2 launch bdd_mjc_pickplace_py launch_mjc_pickplace_stack.yaml gui:=True
```

This starts:

- `bdd_exec_ros2/bdd_coordination_node`
- `bdd_mjc_pickplace_py/mjc_pickplace_node`

## Start the test run

After launching the stack, trigger execution from another terminal:

```bash
source ~/ros_bdd_ws/venv/bin/activate
source ~/ros_bdd_ws/install/setup.bash
ros2 topic pub --once /bdd/start std_msgs/msg/Empty '{}'
```

## Run behaviour node only

```bash
ros2 launch bdd_mjc_pickplace_py launch_mjc_pickplace.yaml
```

With GUI:

```bash
ros2 launch bdd_mjc_pickplace_py launch_mjc_pickplace.yaml gui:=True
```

## Notes

- The current integrated test-execution flow still requires the `/bdd/start` `std_msgs/msg/Empty` trigger.
- `mj_kdl_wrapper` resolves the Kinova model through its menagerie helper, typically from `~/.cache/mj_kdl_wrapper/menagerie`.
