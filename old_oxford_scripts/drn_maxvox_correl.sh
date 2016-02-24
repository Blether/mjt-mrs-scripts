#!/bin/bash

# still trying to do feat for drn correlation 
# use featquery results to get the best drn voxel to use for timeseries
# mjt 2008-03-08

SUBJNO=$1
WORKDIR=${HOME}/scratch/cital_fmri

FQ_DIR=${WORKDIR}/subj_${SUBJNO}_faces.feat/drn_featquery
OUTDIR=${WORKDIR}/drn_correl/${SUBJNO}

MAXTS=${OUTDIR}/${SUBJNO}_drn_maxvox_ts.txt


FOO=`cat ${FQ_DIR}/report.txt |sed -n 1p |gawk '{print $11" " $12" " $13}'`
fslmeants -i ${WORKDIR}/subj_${SUBJNO}_faces.feat/filtered_func_data.nii.gz -o ${MAXTS} -c ${FOO}
