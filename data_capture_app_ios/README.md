# L-AVATeD Image and LiDAR Data Capture Application

## Overview

This is highly modified version of an example application supplied by Apple [Sample Code](https://developer.apple.com/documentation/avfoundation/additional_data_capture/capturing_depth_using_the_lidar_camera)
on iOS. It uses the iPhone TrueDepth camera to capture LiDAR data simultaneously with standard RGB imagery as well as gravimetric data providing device orientation.

The application allows captured data to be labelled into pre-defined classes, and is how the L-AVATeD Image Database was collected.

The data is stored on device in folders per-class, labelled with the session start time.
