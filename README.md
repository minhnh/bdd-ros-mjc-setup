# RobBDD, ROS 2, MuJoCo Setup Automation

Script for setting up a ROS 2 workspace linked to a Python virtual environment, including the BDD coordinator, MuJoCo behaviour node, and all required dependencies.

## Setup

```bash
git clone https://github.com/minhnh/bdd-ros-mjc-setup.git
cd bdd-ros-mjc-setup
./setup-bdd-ros-mjc.sh ~/ros_bdd_ws
```

This setup clones and builds:

- `bdd_exec_ros2`
- `bdd_mjc_pickplace_py`
- `bdd_ros2_interfaces`
- `mj_kdl_wrapper`
- `bdd-dsl`
- `coord-dsl`
- `robbdd`
- `rdf-utils`

It also fetches the MuJoCo menagerie models for `mj_kdl_wrapper`.

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
