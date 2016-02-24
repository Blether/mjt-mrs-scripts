#/usr/local/bin/bash
#
# extract cope1 image from feat first-level analysis to aid later correlational analysis
#
# Matt Taylor 2008-02-13 & 03-03
#
# add stuff so makes a binary mask!
# mjt 2008-09-03

MASK=${1}-mask
SCAN=${2}_mebold_brain

DIRNAME=${SCAN}_ts
#FUNCDATA=${SCAN}.feat/filtered_func_data.nii.gz
#TFORM=${SCAN}.feat/reg/standard2example_func.mat
COPEDATA=${SCAN}.feat/stats/cope1.nii.gz
FUNCMASK=${MASK}_funcspace
BINMASK=${FUNCMASK}_bin

#mkdir ${DIRNAME}
cd ${DIRNAME}
if ! test -f cope1.nii.gz
then
ln -s ../${COPEDATA}
fi

fslmaths ${FUNCMASK} -bin ${BINMASK}
fslmaths cope1 -mul ${BINMASK} cope1_${1}-bin-mul
VAL=`fslstats cope1_${1}-bin-mul -M`
echo ${2} ${VAL}
