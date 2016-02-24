#!/usr/local/bin/bash
#
# use voxel to get composition from hires
#
# simplified version of get_hires_voxcomp.sh
# added correction for translation from voxel mask to true position
# these already used for voxeloverlap calcuylation
#
# mjt 2008-06-23

SUBJ_NO=$1
SCAN_TO_USE=$2
BASEDIR=/home/fs0/taylor/scratch
OUTFILE=${BASEDIR}/cital_hires/voxel_composition_hires.txt
WORKDIR=${BASEDIR}/cital_hires/${SUBJ_NO}
SCAN_ALLOCFILE=${BASEDIR}/cital2_analysis/subject_scans.txt
if [ ${SCAN_TO_USE} == '2' ]
then
SCAN_NO=$( less ${SCAN_ALLOCFILE} |egrep ^${SUBJ_NO} |head -n 1  |awk '{print $3}' )
else
SCAN_NO=$( less ${SCAN_ALLOCFILE} |egrep ^${SUBJ_NO} |head -n 1  |awk '{print $2}' )
fi
LORES_BRAIN2=${BASEDIR}/cital2_analysis/structural/brains/${SCAN_NO}_brain
HIRES_STRUC=${BASEDIR}/cital_hires/subject_${SUBJ_NO}
HIRES_BRAIN=${WORKDIR}/${SUBJ_NO}_brain 
VOX_MASK=${BASEDIR}/cital2_analysis/structural/${SCAN_NO}_voxel
VOX_MASK_HI=${WORKDIR}/${SUBJ_NO}_vox${SCAN_NO}_hires_voxmask
LO22HI_CRUDE_MAT=${WORKDIR}/${SCAN_NO}_to_hires_${SUBJ_NO}_crude.mat
LO22HIMAT=${WORKDIR}/${SCAN_NO}_to_hires_${SUBJ_NO}.mat
if [ ${SCAN_TO_USE} == '2' ]
then
VOX2REALMAT=${BASEDIR}/cital2_analysis/structural/tmp/${SCAN_NO}_voxtoreal.mat
else
TMPVOX2REALMAT=${BASEDIR}/cital2_analysis/structural/tmp/${SCAN_NO}_realtovox.mat
VOX2REALMAT=${BASEDIR}/cital2_analysis/structural/tmp/${SCAN_NO}_voxtoreal.mat
convert_xfm -omat ${VOX2REALMAT} -inverse ${TMPVOX2REALMAT}
fi

MASKLO=0

#make working directory if required
mkdir -p ${WORKDIR}

if ! test -f ${HIRES_BRAIN}.nii.gz
then
/usr/local/fsl/bin/bet ${HIRES_STRUC} ${HIRES_BRAIN} -f 0.5 -g 0
fi

#calculate transform to hires
/usr/local/fsl/bin/flirt -in ${LORES_BRAIN2} -ref ${HIRES_BRAIN} -omat ${LO22HI_CRUDE_MAT} -bins 256 -cost corratio -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 7 -interp trilinear
convert_xfm -omat ${LO22HIMAT} -concat ${LO22HI_CRUDE_MAT} ${VOX2REALMAT} 

#get mask in hires space
/usr/local/fsl/bin/flirt -in ${VOX_MASK} -ref ${HIRES_BRAIN} -out ${VOX_MASK_HI} -applyxfm -init ${LO22HIMAT}

#calculate pve for hires structural brain if needed
if test ! -f ${HIRES_BRAIN}_pve_1.nii.gz
	then
	fast  -t1 -c 3 -n -e -ov ${HIRES_BRAIN}
fi

#get composition with mask onto pve hires
GREY_HI=`fslstats ${HIRES_BRAIN}_pve_1 -k ${VOX_MASK_HI} -m`
WHITE_HI=`fslstats ${HIRES_BRAIN}_pve_2 -k ${VOX_MASK_HI} -m`
CSF_HI=`fslstats ${HIRES_BRAIN}_pve_0 -k ${VOX_MASK_HI} -m`

echo ${SUBJ_NO} ${SCAN_NO} ${GREY_HI} ${WHITE_HI} ${CSF_HI} >>${OUTFILE}
