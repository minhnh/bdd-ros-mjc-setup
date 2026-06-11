# RobBDD, ROS2, Mujoco Setup Automation

Script for setting up a ROS2 workspace linked to a Python virtual environment, which
includes cloning and installing all necessary dependencies.

Sample usage:

```bash
git clone https://github.com/minhnh/bdd-ros-mjc-setup.git
cd bdd-ros-mjc-setup
./setup-bdd-ros-mjc.sh ~/ros_bdd_ws
```

The script includes environment activatoin. In a fresh terminal, the following commands are required to
activate Python and ROS environments:

```bash
source "~/ros_bdd_ws/venv/bin/activate"
source "~/ros_bdd_ws/install/setup.bash"
```

Test run Mujoco example (requires above environment activation):

```bash
python ~/ros_bdd_ws/thirdparty/mj_kdl_wrapper/python/examples/ex_pick.py --gui
```
