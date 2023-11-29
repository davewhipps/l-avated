#!/bin/bash

# This path should point to a folder containing the raw image data, separated
# into folders named by class
RAW_DATA_DIR=raw

OUTPUT_DIR=s2mnet
OUTPUT_DIR_LIDAR=s2mnet_lidar_TIF

# Resize images to this max-width whilst converting to JPG
IMAGE_WIDTH=512

# create a directory to hold the rgb image output (fail if it already exists)
mkdir -p $OUTPUT_DIR

# create a directory to hold the lidar output (fail if it already exists)
mkdir -p $OUTPUT_DIR_LIDAR

# get a list of classnames from the raw data directory
find $RAW_DATA_DIR -maxdepth 1 -mindepth 1 -type d -exec basename {} > classes.txt ';'

# Iterate through each class
while read CLASS; do

  # Create the output directory if it does not exist
  mkdir -p $OUTPUT_DIR/$CLASS;

  # Create the Lidar output directory if it does not exist
  mkdir -p $OUTPUT_DIR_LIDAR/$CLASS;

  # Recursively find all "HEIC" images in each subfolder
  find $RAW_DATA_DIR/$CLASS -type f -name "*.HEIC" -print0 |
    while read -r -d '' IMAGEFILE
    do
      RAWFILENAME=$(basename "$IMAGEFILE" .HEIC)
      OUTFILE=$OUTPUT_DIR/$CLASS/$RAWFILENAME.jpg

      # If an JPEG of the file already exists in the output folder, skip it
      # Otherwise, use 'sips' (Apple Simple Image Processing System) to convert from
      # HEIC to JPEG
      if test -f "$OUTFILE"; then
        echo "$OUTFILE already exists."
      else
        sips -Z $IMAGE_WIDTH -s format jpeg "$IMAGEFILE" --out "$OUTFILE"
      fi

    done

  # Recursively find all "TIF" images in each subfolder
  find $RAW_DATA_DIR/$CLASS -type f -name "*.TIF" -print0 |
    while read -r -d '' LIDARFILE
    do
      INFILE=$LIDARFILE
      cp "$INFILE" $OUTPUT_DIR_LIDAR/$CLASS
    done

done < classes.txt

# [OPTIONAL] Activate a python envioronment
# source ~/tfmodelmaker/bin/activate

# Call the script to convert the Lidar data from 32-bit depth TIF to 8bit/channel jpg
# python3 convert_lidar_data.py

# Call the script to split the data into train/validation/test
# python3 copy_and_split_data.py