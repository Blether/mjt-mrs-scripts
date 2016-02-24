#!/usr/local/bin/bash
# this script gets coordinates for the centre
# of the MRS voxel used and converts it to
# MNI space to allow comparisons between scans
#
# mjt 2007-04

studyid=$1
basedir=/home/fs0/taylor/scratch/${studyid}_analysis/structural
imgdir=${basedir}/brains
voxdir=${basedir}
outfile=${basedir}/voxels_mnispace.txt

# find scans
for i in ${imgdir}/*_brain.nii.gz
do
	file=${i##*/}
	shortid=${file%_*}
	if test -z "` cat ${outfile} |grep "${shortid}" `"
	then
		echo "didn't find ${file}"
	else
		echo "did find ${file}"
	fi
done

