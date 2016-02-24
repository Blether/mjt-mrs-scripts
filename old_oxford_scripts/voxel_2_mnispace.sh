#!/bin/bash
# take voxel mask for individual and move it into MNI space
# help c comparison of voxel positions between individuals
# mjt 2008-12-12
#
# version 2 - deals with the new directory structure and protocols on the siemens
# Matt 2010-04-08

STUDYID=$1
SUBJID=$2
VOXELFILE=$3
BASEDIR=/home/fs0/taylor/scratch/${STUDYID}
WORKDIR=${BASEDIR}/struc/
MNIIMG=${FSLDIR}/data/standard/MNI152_T1_1mm_brain.nii.gz

if test ! -f ${WORKDIR}/${VOXELFILE}.nii.gz
then
	echo could not find voxel mask ${VOXELFILE} , aborting
	exit 0
fi

batch -q short.q flirt -in ${WORKDIR}/${VOXELFILE} -ref ${MNIIMG} -applyxfm -init ${WORKDIR}/brains/${SUBJID}/${SUBJID}_brain_mni.*mat -out ${WORKDIR}/${VOXELFILE}_mni
