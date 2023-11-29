# Create the balanced dataset with 
import splitfolders
import os
import glob
import pathlib
import shutil

INPUT_DIR_RGB="s2mnet"
OUTPUT_DIR_SPLIT_RGB="s2mnet_split"

INPUT_DIR_LIDAR="s2mnet_lidar"
OUTPUT_DIR_SPLIT_LIDAR="s2mnet_split_lidar"

# Use "splitfolders" to separate RGB data into train/valid/test with a ratio
splitfolders.ratio(INPUT_DIR_RGB, output=OUTPUT_DIR_SPLIT_RGB, seed=1337, ratio=(.8, .1, .1) )

# Copy the exact same Lidar files into the same heirarchy
def copy_matching_lidar_img_for_path( train_test_val, rgb_file ):
	# Find the source Lidar file we want to copy based on the name and 
    # containing folder of the passed RGB file
    source_lidar_file = rgb_file.replace( os.path.join( OUTPUT_DIR_SPLIT_RGB, train_test_val), INPUT_DIR_LIDAR)
    source_lidar_file = source_lidar_file.replace('.jpg', '_depth.jpg')
    # TODO: how do I get train_test_val in here
    dest_lidar_file = source_lidar_file.replace( INPUT_DIR_LIDAR, os.path.join( OUTPUT_DIR_SPLIT_LIDAR, train_test_val) )
    os.makedirs( os.path.dirname( dest_lidar_file ), exist_ok=True ) 
    shutil.copyfile( source_lidar_file, dest_lidar_file )

# Splitfolders creates test/train/val. We want to mirror that heirarchy
# Iterate over each of the test/train/val folders for the RGB files, and copy the
# corresponding Lidar file to the corresponding folder

# TEST folder
count_test = 0
for rgb_file in glob.glob( os.path.join( OUTPUT_DIR_SPLIT_RGB, 'test', '*/*.jpg' ) ):
	copy_matching_lidar_img_for_path( 'test', rgb_file )
	count_test = count_test + 1
	
# TRAIN folder
count_train = 0
for rgb_file in glob.glob( os.path.join( OUTPUT_DIR_SPLIT_RGB, 'train', '*/*.jpg' ) ):
	copy_matching_lidar_img_for_path( 'train', rgb_file )
	count_train = count_train + 1

# VAL folder
count_val = 0
for rgb_file in glob.glob( os.path.join( OUTPUT_DIR_SPLIT_RGB, 'val', '*/*.jpg' ) ):
	copy_matching_lidar_img_for_path( 'val', rgb_file )
	count_val = count_val + 1        

print ( "Successfully copied ", count_test, " files from ", INPUT_DIR_LIDAR, "/test to ", OUTPUT_DIR_SPLIT_LIDAR, "/test")
print ( "Successfully copied ", count_train, " files from ", INPUT_DIR_LIDAR, "/train to ", OUTPUT_DIR_SPLIT_LIDAR, "/train")
print ( "Successfully copied ", count_val, " files from ", INPUT_DIR_LIDAR, "/val to ", OUTPUT_DIR_SPLIT_LIDAR, "/val")