#!/bin/bash
MAINDIR=/home/fs0/taylor/scratch/ketamine_analysis
for SUBD in pre post1 post2 post3; do
ketlcm.sh ketamine ${1} ${SUBD}
done
# work out which series is the structural one
BIGDIR=`ls -l ${MAINDIR}/original_scans/${1}/processed_data/ |tr -s '' |sort -r -n -k5 |head -n 1 |gawk '{print $9}'`
STRUCSERIES=${BIGDIR%%.nii.gz}
STRUC=${STRUCSERIES##series_}

batch -q short.q ~/scripts/struc_analysis_bits.sh ${1} ${STRUC} ${MAINDIR} ketamine

#prep things for teav analysis
for SUBD in pre post1 post2 post3; do
mkdir -p ${MAINDIR}/teav_analysis/${1%%_*}/${SUBD}
cd ${MAINDIR}/teav_analysis/${1%%_*}/${SUBD}
~/.lcmodel/varian/varian2raw ${MAINDIR}/original_scans/${1}/${SUBD}/press_teavg.fid/fid ./
cd ..
done
