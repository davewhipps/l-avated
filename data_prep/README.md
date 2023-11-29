# L-AVATeD Image Dataset Pre-Processing Scripts

## Overview

This folder contains scripts for pre-processing data captured by the `data_capture_app_ios` to create the L-AVATeD Image Dataset.

The first script, `clean_and_convert_images.sh` runs only on macOS (but could easily be converted to run on 'nix based systems, by replacing `sips` with e.g. ImageMagick) and reads the source data from a `raw` data directory which must contain output from the `data_capture_app_ios` copied from the device.

The subfolders of the `raw` folder must be the class labels e.g. "grass", "stairs-up" each of which may contain data-named subfolders, e.g. "Apr 28, 2023 at 9/47/16 AM" which themselves contain the raw image, lidar and gravity vector data.

In this first data release, the script simply resizes and converts the RGB image data from Apple's ".HEIC" image format to a ".JPEG" file, and copies them into folders labelled with the class name.

The user should then manually run the python script called "convert_lidar_data.py" which uses OpenCV to read, normalize and write out the lidar TIF files into JPEG files which can then more easily be used to train a separate image classifier.

Finally, running "copy_and_split_data.py" splits the image files into train/test/val folders, first doing the RGB images, then copying the matching Lidar files to an analogous folder hierarchy.