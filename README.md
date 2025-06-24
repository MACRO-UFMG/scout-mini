# scout-mini

To run the mapping feat you'll resort to the following commands:

```
ros2 launch scout_bringup start_scout.launch.py 
```

```
python3 scout_ws/src/scout-mini/scout-bringup/scout_bringup/scripts/dynamic_livox_tf.py 
```

```
python3 scout_ws/src/scout-mini/scout-bringup/scout_bringup/scripts/pcl2_cmsg.py
```

```
ros2 run pointcloud_to_laserscan pointcloud_to_laserscan_node
```

```
python3 scout_ws/src/scout-mini/scout-bringup/scout_bringup/scripts/scan_intensity.py 
```

```
ros2 launch fast_lio mapping.launch.py
```

```
ros2 launch slam_toolbox online_async_launch.py
```

```
rosrun nav2_map_server map_saver_cli -f ~/maps/coro --ros-args -p map_subscribe_transient:=true
```