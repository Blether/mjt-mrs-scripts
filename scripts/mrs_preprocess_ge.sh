#!/bin/bash
# do preprocessing of GE MRS data
# Matthew Taylor 2011-12-11

PFILE_FULL=$1
PFILE=${1%*.*} # remove trailing extension if poss, e.g. .7
INSTRUCIMG=$2
STRUCIMG=${PFILE}_struc
PICNAME=${PFILE}_voxel

#geimg2niigz.sh ${INSTRUCIMG} ${STRUCIMG} 
# better to get dicom data and convert with dcm2nii (from MRIcron people)

voxpos_ge.py ${PFILE_FULL}
voxmask_ge.py ${PFILE_FULL} ${STRUCIMG}

voxel_position_pic.sh ${PFILE}_voxel_mask.nii.gz ${STRUCIMG} ${PFILE}_vox

