#!/usr/local/bin/bash
#
# cital2 study
# make voxels in MNI space to allow show position
#
# mjt 2008-06-27

STUDYID=cital2
SCANID=${1}

BASEDIR=/home/fs0/taylor/scratch/${STUDYID}_analysis/structural
OUTDIR=${BASEDIR}/vox_mni_new

flirt -in ${BASEDIR}/brains/${SCANID}_brain -ref ${OUTDIR}/MNI152_T1_1mm_brain.nii.gz -omat ${OUTDIR}/${SCANID}_to_mni.mat
flirt -in ${BASEDIR}/${SCANID}_voxel -ref ${OUTDIR}/MNI152_T1_1mm_brain.nii.gz -applyxfm -init  ${OUTDIR}/${SCANID}_to_mni.mat -out ${OUTDIR}/${SCANID}_voxel_mni
