#!/usr/bin/env bash
# Usage: ./setup-bdd-ros-mjc.sh ~/path/to/ros_ws_root
WS_ROOT=$1

# expand path
WS_ROOT=$(realpath -s "$WS_ROOT")

if [ -z "$WS_ROOT" ]; then
  echo "Usage: $0 ~/path/to/ros_ws_root"
  echo "Optional: ROS_VER=rolling $0 ~/path/to/ros_ws_root"
  exit 1
fi

# Default ROS version: jazzy
if [ -z "$ROS_VER" ]; then
  ROS_VER="jazzy"
fi
echo "ROS version: $ROS_VER"

if [ ! -d "$WS_ROOT/src" ]; then
  echo "creating directory '$WS_ROOT/src'"
  mkdir -p "$WS_ROOT/src"
fi

# Clone dependencies using vcstool
REPO_FILE="./bdd-ros2-mjc.repos"
if [ ! -f "$REPO_FILE" ]; then
  echo "missing repo file '$REPO_FILE'"
  exit 1
fi

if ! vcs --version > /dev/null 2>&1 ; then
  echo "vcs command not found, install with sudo apt install python3-vcstool"
  exit 1
fi
echo "cloning dependencies into $WS_ROOT"
vcs import "$WS_ROOT" < "$REPO_FILE"
touch "$WS_ROOT/thirdparty/COLCON_IGNORE"

# Set ROS versions for relevant repos
set_repo_branch () {
  REPO_DIR="$1"
  BRANCH="$2"
  echo "Switching to branch $BRANCH in $REPO_DIR"
  cd "$REPO_DIR"
  git checkout "$BRANCH"
  cd -
}

set_repo_branch "$WS_ROOT/src/bdd_exec_ros2" "$ROS_VER"
set_repo_branch "$WS_ROOT/src/bdd_mjc_pickplace_py" "$ROS_VER"

# Setup Python virtual environment
source "/opt/ros/$ROS_VER/setup.bash"
if uv --version > /dev/null 2>&1 ; then
  echo "Using uv instead of pip"
  PIP_CMD="uv pip"
  VENV_CMD="uv venv"
else
  PIP_CMD="pip"
  VENV_CMD="python -m venv"
fi
VENV_DIR="$WS_ROOT/venv"
if [ -d "$VENV_DIR" ]; then
  echo "virtual environment exists at: $VENV_DIR"
else
  echo "creating ROS compatible Python virtual environment"
  $VENV_CMD --system-site-packages "$VENV_DIR"
fi
touch "$VENV_DIR/COLCON_IGNORE"

# Copy cmake configurations to ROS workspace
copy_file_to_ws_root () {
  FILE_NAME=$1
  if [ -f "$WS_ROOT/$FILE_NAME" ] ; then
    echo "won't overwrite existing file $WS_ROOT/$FILE_NAME"
  elif [ ! -f "./$FILE_NAME" ] ; then
    echo "can't copy, file ./$FILE_NAME doesn't exist"
  else
    echo "copying $FILE_NAME to $WS_ROOT"
    cp "./${FILE_NAME}" "${WS_ROOT}"
  fi
}
#copy_file_to_ws_root "colcon.meta"
copy_file_to_ws_root "colcon_defaults.yaml"

# Build ROS workspace & activate environments
echo "entering '$WS_ROOT'"
cd "$WS_ROOT"
colcon build
source "${WS_ROOT}/venv/bin/activate"
source "${WS_ROOT}/install/setup.bash"

# Instal Python dependencies
$PIP_CMD install pyside6  # for visualization script
$PIP_CMD install -e "${WS_ROOT}/thirdparty/rdf-utils[all]"
$PIP_CMD install -e "${WS_ROOT}/thirdparty/bdd-dsl"
$PIP_CMD install -e "${WS_ROOT}/thirdparty/scene-dsl"
$PIP_CMD install -e "${WS_ROOT}/thirdparty/robbdd"
$PIP_CMD install -e "${WS_ROOT}/thirdparty/coord-dsl"
# clean up previous build
if [ -d "${WS_ROOT}/thirdparty/mj_kdl_wrapper/build" ] ; then
  rm -rf "${WS_ROOT}/thirdparty/mj_kdl_wrapper/build"
fi
$PIP_CMD install -e "${WS_ROOT}/thirdparty/mj_kdl_wrapper"
mj-kdl-fetch-menagerie  # should be installed into venv with mj_kdl_wrapper
