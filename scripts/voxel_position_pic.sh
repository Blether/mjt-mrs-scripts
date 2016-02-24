#!/bin/bash
# 2012-12-14

VOXMASK=${1}
STRUCIMG=${2}
PICNAME=${3}

# produce picture of mask position for easy reference
# don't need to use 'overlay' separately - edges of voxel can be drawn on
# within slicer itself
# make slice images - standard axes & also through voxel centre
slicer ${STRUCIMG} ${VOXMASK} -a ${PICNAME}.ppm

# convert output image
convert ${PICNAME}.ppm a_${PICNAME}.png
rm ${PICNAME}.ppm

# fslstats the voxel mask for its centre
# slice through voxel centre
XVOXSLICE=`fslstats ${VOXMASK} -C | awk '{printf "%d\n", $1}'`
slicer ${STRUCIMG} ${VOXMASK} -x -${XVOXSLICE} x_${PICNAME}.ppm
YVOXSLICE=`fslstats ${VOXMASK} -C | awk '{printf "%d\n", $2}'`
slicer ${STRUCIMG} ${VOXMASK} -y -${YVOXSLICE} y_${PICNAME}.ppm
ZVOXSLICE=`fslstats ${VOXMASK} -C | awk '{printf "%d\n", $3}'`
slicer ${STRUCIMG} ${VOXMASK} -z -${ZVOXSLICE} z_${PICNAME}.ppm

convert +append x_${PICNAME}.ppm y_${PICNAME}.ppm z_${PICNAME}.ppm xyz_${PICNAME}.png
rm x_${PICNAME}.ppm y_${PICNAME}.ppm z_${PICNAME}.ppm

convert -append a_${PICNAME}.png xyz_${PICNAME}.png ${PICNAME}.png
rm a_${PICNAME}.png xyz_${PICNAME}.png 
