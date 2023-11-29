import os
import glob
import matplotlib.pyplot as plt
import numpy as np
import cv2
import pathlib

INPUT_DIR="s2mnet_lidar_TIF"
OUTPUT_DIR="s2mnet_lidar"

def convert_lidar_img_at_path(file_path):
	# TIFF images are stored as 32-bit data
	img = cv2.imread(file_path, flags=(cv2.IMREAD_GRAYSCALE | cv2.IMREAD_ANYDEPTH) )
	# Because we didn't ask iOS to interpolate, the image includes NaNs, which we'll convert to zeros here.
	cv2.patchNaNs(img, 0)
	img = cv2.normalize(img, None, 0.0, 1.0, cv2.NORM_MINMAX, dtype=cv2.CV_32F)
	img = cv2.cvtColor(img, cv2.COLOR_GRAY2RGB) # we need 3 channel for our neural networks

	encode_param = [int(cv2.IMWRITE_JPEG_QUALITY), 100]
	success, buffer = cv2.imencode('.jpg', 255.0*img, encode_param)
	new_path = file_path.replace(INPUT_DIR, OUTPUT_DIR)
	os.makedirs( os.path.dirname( new_path), 0o777, True )
	new_path = new_path.replace(".TIF", '.jpg')
	buffer.tofile(new_path)

# iterate over folders in the root directory
for file in glob.glob( os.path.join( INPUT_DIR, '*/*.TIF' ) ):
	convert_lidar_img_at_path( file )