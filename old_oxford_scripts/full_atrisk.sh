#!/bin/bash
MAINDIR=/home/fs0/taylor/scratch/atrisk_analysis
runlcm_mt.sh atrisk ${1}
# work out which series is the structural one
BIGDIR=`ls -l ${MAINDIR}/original_scans/${1}/processed_data/ |tr -s '' |sort -r -n -k5 |head -n 1 |gawk '{print $9}'`
STRUCSERIES=${BIGDIR%%.nii.gz}
STRUC=${STRUCSERIES##series_}

batch -q short.q ~/scripts/struc_analysis_bits.sh ${1} ${STRUC} ${MAINDIR} atrisk

#prep things for teav analysis
mkdir -p ${MAINDIR}/teav_analysis/${1%%_*}
cd ${MAINDIR}/teav_analysis/${1%%_*}
~/.lcmodel/varian/varian2raw ${MAINDIR}/original_scans/${1}/press_teavg.fid/fid ./
cd ..
