#!/bin/bash
# compare theta values for voxel and the structural image
# mjt 2008-12-16

STUDYID=$1
SCANID=$2
BASEDIR=${HOME}/scratch/${STUDYID}_analysis
OUTFILE=${BASEDIR}/structural/thetas.txt

VOXTHETA=` cat ${SCANID}.voxel |grep theta | gawk '{print $5}'`

echo ${SCANID} ${VOXTHETA}
