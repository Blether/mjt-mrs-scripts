#!/bin/bash
# script to calculate constituents in voxel
# derived from one received from Charlie Stagg
# mjt 2007-03-22
# changes to do all three components not just gm
# Matthew Taylor 2007-08-16
#
# version 2 - works with siemens files now
# need to make work with mask image, not .voxel file
# 
# Matt 2008-04-08

DIR=${HOME}/scratch/${1}/struc
#INDIV=${2%%_*}
INDIV=${2}
VOXIMG=${DIR}/${3}
BRAINIMG=${DIR}/brains/${INDIV}/${INDIV}_brain
OUTFILE=${DIR}/voxel_contents.txt

# segment image if required
if test ! -f ${BRAINIMG}_pve_2.nii.gz
then

	# abort if brain image not available
	if test ! -f ${BRAINIMG}.nii.gz
	then
		echo could not find ${INDIV} brain image, aborting
		exit 0
	fi
# partial volume segmentation
	echo partial volume segmentation in process, ${INDIV}
	fast  -t 1 -n 3 ${BRAINIMG}
fi


# change to use fslstats and mask image, rather than fslroi
#fslroi ${DIR}/brains/${INDIV}_brain_pve_1 ${DIR}/voxel_grey ${x_correct} ${x_size} ${y_correct} ${y_size} ${z_correct} ${z_size}
#fslroi ${DIR}/brains/${INDIV}_brain_pve_0 ${DIR}/voxel_csf ${x_correct} ${x_size} ${y_correct} ${y_size} ${z_correct} ${z_size}
#fslroi ${DIR}/brains/${INDIV}_brain_pve_2 ${DIR}/voxel_white ${x_correct} ${x_size} ${y_correct} ${y_size} ${z_correct} ${z_size}

grey_percent=`fslstats ${BRAINIMG}_pve_1 -k ${VOXIMG} -m -v | gawk -F ' ' '{print $1}'`
total_volume=`fslstats ${BRAINIMG}_pve_1 -k ${VOXIMG} -m -v | gawk -F ' ' '{print $3}'`
volume_of_grey=`echo ${grey_percent}*${total_volume} | bc` 
white_percent=`fslstats ${BRAINIMG}_pve_2 -k ${VOXIMG} -m `
csf_percent=`fslstats ${BRAINIMG}_pve_0 -k ${VOXIMG} -m`

echo grey_percent = ${grey_percent}
echo total_vol = ${total_volume}
echo volume of grey = ${volume_of_grey}
echo white_percent = ${white_percent}
echo csf_percent = ${csf_percent}
echo ${INDIV} ${3} ${grey_percent} ${white_percent} ${csf_percent} ${total_volume} >> ${OUTFILE}

