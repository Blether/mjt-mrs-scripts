#!/bin/bash
#
# extracts brain etc, puts it in the correct place
# the various commandline parameters are from running the gui with defaults
# so nothing too unusual probably
#
# mjt 2007-04
#
# version 2
# works with siemens data, also soem changes to directory structure
# Matt Taylor 2010-08-04

STUDYID=$1
INDIV=$2
BASEDIR=${HOME}/scratch/${STUDYID}
MNIBRAIN=/usr/local/fsl/data/standard/MNI152_T1_1mm_brain
BRAINDIR=${BASEDIR}/struc/brains/${INDIV}

if [ "$3" == "" ] ;
then
STRUCIMG=${BASEDIR}/original_scans/${INDIV}/images/${INDIV}/*anat*nii.gz
else
STRUCIMG=${BASEDIR}/original_scans/${INDIV}/${3}
fi

if test ! -f ${STRUCIMG} ; then echo image not found; exit 1; fi

mkdir -p ${BRAINDIR}

#echo $INDIV $INDIV $BASEDIR $STRUCIMG $BRAINDIR

#/usr/local/fsl/bin/load_varian ${STRUCIMG} ${BRAINDIR}/${INDIV} -ms -bl -ft3d -fermi -resl -rot -pss -mod -16 -niigz  

/usr/local/fsl/bin/bet ${STRUCIMG} ${BRAINDIR}/${INDIV}_brain -f 0.5 -g 0

/usr/local/fsl/bin/flirt -in ${BRAINDIR}/${INDIV}_brain.nii.gz -ref ${MNIBRAIN} -out ${BRAINDIR}/${INDIV}_brain_mni.nii.gz -omat ${BRAINDIR}/${INDIV}_brain_mni.mat -bins 256 -cost corratio -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 12  -interp trilinear

