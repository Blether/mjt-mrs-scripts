#!/usr/local/bin/bash
#
# gets overall measure of muscle tissue signal
# to allow for correction of global effects
# c.f. Andrew lowe's paper 2007
#
#
# $1 - functional image
# $2 - cns mask
# $3 - mask over arbitrary area of muscle tissue

WORKDIR='/vols/Scratch/taylor/physiol/serine'
FUNCIMAGE=$1
if [ "$2" == "" ]
then
CNSMASK=$1-mask
MUSCLEMASK=$1-mask_muscle
else
CNSMASK=$2
MUSCLEMASK=$3
fi
TMPDIR=${WORKDIR}/globalsignal
OUTFILE=${1}_muscle.txt

ICNSMASK=${TMPDIR}/${CNSMASK}_i
NONCNSMEAN=${TMPDIR}/${FUNCIMAGE}_notcns

fslmaths ${CNSMASK} -mul -1 -add 1 ${ICNSMASK}
fslmaths ${FUNCIMAGE} -Tmean -mas ${ICNSMASK} ${NONCNSMEAN}

MMEAN=`fslstats ${TMPDIR}/${FUNCIMAGE}_notcns -k ${MUSCLEMASK} -M`
MSD=`fslstats ${TMPDIR}/${FUNCIMAGE}_notcns -k ${MUSCLEMASK} -S`
THRES=` echo ${MMEAN} - ${MSD} | bc `

echo thresholding values at ${THRES}

fslmaths ${TMPDIR}/${FUNCIMAGE}_notcns -thr ${THRES} -bin ${TMPDIR}/${FUNCIMAGE}-mask_muscle
fslmeants -i ${FUNCIMAGE} -o ${OUTFILE} -m ${TMPDIR}/${FUNCIMAGE}-mask_muscle

