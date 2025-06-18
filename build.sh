#!/bin/bash

# Exit immediately if a command fails.
set -e

# --- Configuration and Constants ---

# Get the absolute path of the directory where the script is located.
# This makes the script portable, no matter where it's called from.
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

# Define important paths based on the script's location.
# It assumes the structure is: ~/ros2_ws/src/scout-mini/
WORKSPACE_DIR=$(realpath "${SCRIPT_DIR}/../..")
LIVOX_PKG_DIR="${SCRIPT_DIR}/livox_ros_driver2"

# Check if the expected directories exist.
if [ ! -d "$WORKSPACE_DIR" ] || [ ! -d "$LIVOX_PKG_DIR" ]; then
    echo "Error: Could not find the expected directories."
    echo "Please check if the script is in '~/ros2_ws/src/scout-mini/' and the project structure is correct."
    exit 1
fi

echo "Workspace Directory: ${WORKSPACE_DIR}"
echo "Livox Package Directory: ${LIVOX_PKG_DIR}"


# --- Script Logic ---

# 1. Navigate to the workspace root.
cd "${WORKSPACE_DIR}"
echo "Changed working directory to: $(pwd)"

# 2. Clean up old build artifacts in the workspace root.
#echo "Cleaning up previous build artifacts (build/, install/, log/)..."
#rm -rf build/ install/ log/

# 3. Prepare the Livox package files for the build.
echo "Preparing Livox driver files..."

# Copy the ROS 2 specific package.xml.
echo "Copying 'package_ROS2.xml' to 'package.xml'..."
cp -f "${LIVOX_PKG_DIR}/package_ROS2.xml" "${LIVOX_PKG_DIR}/package.xml"

# Copy the ROS 2 launch files.
echo "Copying ROS 2 launch directory..."
# Ensure the destination directory doesn't exist to avoid issues with cp.
rm -rf "${LIVOX_PKG_DIR}/launch"
cp -rf "${LIVOX_PKG_DIR}/launch_ROS2/" "${LIVOX_PKG_DIR}/launch/"

# 4. Run the build with colcon.
echo "Starting 'colcon build'..."
colcon build --cmake-args -DROS_EDITION=ROS2

# 5. Clean up temporary files created for the build.
echo "Cleaning up temporary launch files..."
rm -rf "${LIVOX_PKG_DIR}/launch/"

echo "-------------------------------------"
echo "Build completed successfully!"
echo "-------------------------------------"

