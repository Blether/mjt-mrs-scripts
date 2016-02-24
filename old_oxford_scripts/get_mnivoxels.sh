#!/usr/local/bin/bash
# this script gets coordinates for the centre
# of the MRS voxel used and converts it to
# MNI space to allow comparisons between scans
#
# mjt 2007-04

#basedir='/home/fs0/taylor/scratch/recdep_analysis/structural'
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
	destfile=${imgdir}/${shortid}_brain_mni.nii

	if test -z "` cat ${outfile} |grep "${shortid}" `"
	then
	
	corner=$(cat $voxdir/${shortid}.voxel)
	echo $corner | gawk '{print ($1 + $4/2) " " ($2 + $5/2) " " ($3 + $6/2)}' > ${voxdir}/test.position

# use img2imgcoords to convert
	mnicentre=$(img2imgcoord -src $i -dest ${destfile}.gz -xfm ${destfile}.mat ${voxdir}/test.position |tail -n 1 )
	echo ${shortid} ${mnicentre} >>${outfile}
	fi

done
cat ${outfile} | sort | uniq > ${outfile}
