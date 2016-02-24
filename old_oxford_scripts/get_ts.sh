#!/usr/local/bin/bash

BASENAME=$1
REGION=$2
REFBASE=11_mebold

# make transform between spaces via template

REFTEMPMAT=../${REFBASE}_brain+.feat/reg/example_func2standard.mat
TEMPBASMAT=../${BASENAME}_brain+.feat/reg/standard2example_func.mat

convert_xfm -omat combined.mat -concat ${TEMPBASMAT} ${REFTEMPMAT}

# transform the mask
flirt -in ../${REFBASE}_brain-mask_${REGION}.nii.gz -ref ../${BASENAME}_brain.nii.gz -applyxfm -init combined.mat -out ${REGION}_newmask

# get timeseries
fslmeants -i ../${BASENAME}_brain.nii.gz -o ${BASENAME}_${REGION}.txt -m ${REGION}_newmask
