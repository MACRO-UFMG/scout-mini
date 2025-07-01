# Scout Mini ROS 2 Jazzy Docker Image for Jetson Orin
# Includes scout_bringup, scout_ros2, ugv_sdk, and Intel RealSense packages pre-built
# Use Ubuntu 24.04 as base image (Noble) which is the recommended platform for ROS 2 Jazzy
FROM ubuntu:24.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install basic dependencies
RUN apt-get update && apt-get install -y \
    curl \
    gnupg2 \
    lsb-release \
    software-properties-common \
    sudo \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Add ROS 2 apt repository
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null

# Add Gazebo apt repository
RUN curl -sSL https://packages.osrfoundation.org/gazebo.gpg -o /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null

# Install ROS 2 Jazzy and Gazebo Harmonic
RUN apt-get update && apt-get install -y \
    ros-jazzy-desktop-full \
    ros-jazzy-ros-gz \
    gz-harmonic \
    && rm -rf /var/lib/apt/lists/*

# Install development tools and dependencies for Scout Mini + RealSense
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    python3-colcon-common-extensions \
    python3-pip \
    python3-rosdep \
    python3-vcstool \
    python3-venv \
    libasio-dev \
    libserial-dev \
    # Additional missing packages
    dkms \
    python3-tqdm \
    python3-requests \
    # Scout Mini ROS packages
    ros-jazzy-joint-state-publisher \
    ros-jazzy-robot-state-publisher \
    ros-jazzy-xacro \
    ros-jazzy-tf2-ros \
    ros-jazzy-tf2-geometry-msgs \
    ros-jazzy-geometry-msgs \
    ros-jazzy-sensor-msgs \
    ros-jazzy-nav-msgs \
    ros-jazzy-std-msgs \
    ros-jazzy-launch-testing-ament-cmake \
    # Intel RealSense dependencies
    libudev-dev \
    pkg-config \
    libgtk-3-dev \
    libusb-1.0-0-dev \
    libglfw3-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    ros-jazzy-cv-bridge \
    ros-jazzy-image-transport \
    ros-jazzy-tf2 \
    ros-jazzy-tf2-eigen \
    ros-jazzy-diagnostic-updater \
    ros-jazzy-angles \
    && rm -rf /var/lib/apt/lists/*

# Initialize rosdep
RUN rosdep init && rosdep update

# Set up environment variables
ENV ROS_DISTRO=jazzy
ENV GZ_VERSION=harmonic

# Create a non-root user
ARG USERNAME=ros
ARG USER_UID=2000
ARG USER_GID=2000

# Create the user and group
RUN groupadd -g $USER_GID $USERNAME && \
    useradd -m -u $USER_UID -g $USER_GID -s /bin/bash $USERNAME && \
    echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME

# Set up workspace and bashrc as root
RUN mkdir -p /home/$USERNAME/ros2_ws/src && \
    echo "source /opt/ros/jazzy/setup.bash" >> /home/$USERNAME/.bashrc && \
    echo "source /home/$USERNAME/ros2_ws/install/setup.bash" >> /home/$USERNAME/.bashrc && \
    chown -R $USERNAME:$USERNAME /home/$USERNAME

# Copy Scout Mini and RealSense packages source code
COPY scout_ws/src/scout-bringup /home/$USERNAME/ros2_ws/src/scout-bringup
COPY scout_ws/src/scout_ros2 /home/$USERNAME/ros2_ws/src/scout_ros2
COPY scout_ws/src/ugv_sdk /home/$USERNAME/ros2_ws/src/ugv_sdk
COPY scout_ws/src/librealsense /home/$USERNAME/ros2_ws/src/librealsense
COPY scout_ws/src/realsense-ros /home/$USERNAME/ros2_ws/src/realsense-ros

# Copy and set up entrypoint script (as root)
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set ownership of copied files
RUN chown -R $USERNAME:$USERNAME /home/$USERNAME/ros2_ws

# Switch to non-root user
USER $USERNAME
WORKDIR /home/$USERNAME/ros2_ws

# Update rosdep for the ros user and install dependencies for Scout Mini and RealSense packages
# Skip ros-jazzy-launch-pytest as it is unavailable
RUN /bin/bash -c "source /opt/ros/jazzy/setup.bash && \
    rosdep update && \
    rosdep install --from-paths src --ignore-src -r -y --skip-keys='ros-jazzy-launch-pytest' || true"

# List available packages for debugging
RUN /bin/bash -c "source /opt/ros/jazzy/setup.bash && \
    colcon list --names-only"

# Try building ugv_sdk as a standalone CMake package first
RUN /bin/bash -c "source /opt/ros/jazzy/setup.bash && \
    cd src/ugv_sdk && \
    mkdir -p build && cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release && \
    make -j$(nproc) && \
    sudo make install && \
    sudo ldconfig"

# Build Scout packages (now that ugv_sdk is installed system-wide)
RUN /bin/bash -c "source /opt/ros/jazzy/setup.bash && \
    colcon build --packages-select scout_msgs scout_base scout_description --cmake-args -DCMAKE_BUILD_TYPE=Release"

# Build Scout bringup and additional utilities
RUN /bin/bash -c "source /opt/ros/jazzy/setup.bash && \
    source install/setup.bash && \
    colcon build --packages-select scout_bringup pointcloud_to_laserscan --cmake-args -DCMAKE_BUILD_TYPE=Release"

# Build RealSense packages (optional - can be built later)
RUN /bin/bash -c "source /opt/ros/jazzy/setup.bash && \
    source install/setup.bash && \
    colcon build --packages-select realsense2_camera_msgs realsense2_description --cmake-args -DCMAKE_BUILD_TYPE=Release || echo 'RealSense packages build failed - will be available for manual build'"

# Set entrypoint
ENTRYPOINT ["/entrypoint.sh"]

# Default command
CMD ["/bin/bash"] 