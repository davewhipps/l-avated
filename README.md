# L-AVATeD Image Dataset Documentation

## Overview

The L-AVATeD Image Dataset consists of pairs of RGB and LiDAR image data categorized into 9 classes of walking terrain. The 9 classes are: banked-left, banked-right, flat-even, irregular, grass, sloped-down, sloped-up, stairs-down, stairs-up.

The class names are generally self-explanatory. The `banked-` classes were applied in cases where the terrain declined significantly, perpendicular to the direction of motion (note that these surfaces may have been made of grass). The `flat-even` class was a base-case; indicating any terrain that was generally smooth and neither sloped, banked or grassy. `Irregular` surfaces were defined as those that were flat (i.e. not banked or sloped), but not smooth, having enough irregularity that they might be expected to materially affect gait (e.g. large gravel). Surfaces were labelled as `grass` if they were generally flat, similar to irregular in that they should be neither sloped nor banked, and consisted primarily of typical short grass or lawn found in North America. `sloped-up` and `sloped-down` are any surface (including grass) which had a significant incline or decline in the immediate direction of motion. `stairs-` were the easiest to classify, and consisted of stairs of any material.

## Data collection

Data was captured by 3 healthy adults. A mobile device (one iPhone 12 Pro, two iPhone 14 Pros) was used to capture simultaneous RGB and LiDAR images using the front-facing camera and built-in LiDAR sensor. Phones were strapped to the researchers using a chest harness with the devices in landscape orientation. Researchers would choose the class label based on their assessment of the local terrain, initiate data capture on the device, and walk, capturing simultaneous image pairs at 1 Hz.

Data were labelled in sequence, with a prefix indicating their order of capture, and a unique suffix in the form of a UUID. Every image pair has the same name, apart from an additional suffix "_depth" on the LiDAR disparity map and their file extension.

A highly modified version of this [sample project from Apple](https://developer.apple.com/documentation/avfoundation/additional_data_capture/capturing_depth_using_the_lidar_camera) was used to capture the data. More information on the LiDAR data format can be found by examining the code and the relevant Apple Documentation. 

## Data types

RGB images were stored in the Apple native image format HEIC and resized and converted to JPEG (in `lavated_split.zip`) using Apple's `sips` command line tool. See: `clean_and_convert_images.sh`.


Depth data was stored as a disparity map (i.e. 1/distance) and saved into a TIFF file as 32-bit grayscale. Care should be taken when attempting to work with this disparity data, as many image manipulation software packages are not equipped to properly read the format. See the script `convert_lidar_data.py` for an example of how to properly read this data using OpenCV.
