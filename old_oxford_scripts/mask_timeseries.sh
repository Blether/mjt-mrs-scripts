#/usr/local/bin/bash
#
# extract the timeseries data from a given mask (defined in standard i.e. paxinos space) for a given preprocessed fmri dataset
#
# Matt Taylor 2008-02-13

MASK=${1}-mask
SCAN=${2}_mebold_brain

DIRNAME=${SCAN}_ts
FUNCDATA=${SCAN}.feat/filtered_func_data.nii.gz
TFORM=${SCAN}.feat/reg/standard2example_func.mat

mkdir ${DIRNAME}
cd ${DIRNAME}
ln -s ../${FUNCDATA}
flirt -in ../${MASK} -ref filtered_func_data -applyxfm -init ../${TFORM} -out ${MASK}_funcspace
fslmeants -i filtered_func_data -m ${MASK}_funcspace -o ${1}_ts.txt
fsl_tsplot -i ${1}_ts.txt -o ${1}_ts.png
