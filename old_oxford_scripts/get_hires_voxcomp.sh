#!/usr/local/bin/bash
#
# calculate voxel compositions for cital2 study scan ones's to compare to those produce
# using the 2x2x2 voxel dimension struc
# also for fairness what if transform mask onto 2x2x2 space too
#
# mjt 2008-11-06
#
# NB - problem iwth lores mask not fitting the brains!
# workaround added below
# sun22 June - need to use awk not gawk to get work on queues

SUBJ_NO=$1
BASEDIR=/home/fs0/taylor/scratch
OUTFILE=${BASEDIR}/cital_hires/vox_composition_lo_hi_res.txt
WORKDIR=${BASEDIR}/cital_hires/${SUBJ_NO}
SCAN_ALLOCFILE=${BASEDIR}/cital2_analysis/subject_scans.txt
SCANONE_NO=$( less ${SCAN_ALLOCFILE} |egrep ^${SUBJ_NO} |head -n 1  |awk '{print $2}' )
SCANTWO_NO=$( less ${SCAN_ALLOCFILE} |egrep ^${SUBJ_NO} |head -n 1  |awk '{print $3}' )
LORES_BRAIN1=${BASEDIR}/cital2_analysis/structural/brains/${SCANONE_NO}_brain
LORES_BRAIN2=${BASEDIR}/cital2_analysis/structural/brains/${SCANTWO_NO}_brain
HIRES_STRUC=${BASEDIR}/cital_hires/subject_${SUBJ_NO}
HIRES_BRAIN=${WORKDIR}/${SUBJ_NO}_brain 
VOX_MASK=${BASEDIR}/cital2_analysis/structural/${SCANONE_NO}_voxel
VOX_MASK_LO2=${WORKDIR}/${SUBJ_NO}_${SCANTWO_NO}_voxmask
LO2LO2MAT=${WORKDIR}/${SCANONE_NO}_to_${SCANTWO_NO}.mat
VOX_MASK_HI=${WORKDIR}/${SUBJ_NO}_hires_voxmask
LO2HIMAT=${WORKDIR}/${SCANONE_NO}_to_hires_${SUBJ_NO}.mat

MASKLO=0

#make working directory if required
mkdir -p ${WORKDIR}
/usr/local/fsl/bin/bet ${HIRES_STRUC} ${HIRES_BRAIN} -f 0.5 -g 0
#calculate transform to hires
/usr/local/fsl/bin/flirt -in ${LORES_BRAIN1} -ref ${HIRES_BRAIN} -omat ${LO2HIMAT} -bins 256 -cost corratio -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 7 -interp trilinear
#get mask in hires space
/usr/local/fsl/bin/flirt -in ${VOX_MASK} -ref ${HIRES_BRAIN} -out ${VOX_MASK_HI} -applyxfm -init ${LO2HIMAT}

#calculate transform to lores2
/usr/local/fsl/bin/flirt -in ${LORES_BRAIN1} -ref ${LORES_BRAIN2} -omat ${LO2LO2MAT} -bins 256 -cost corratio -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 6  -interp trilinear
#get mask in lores2 space
/usr/local/fsl/bin/flirt -in ${VOX_MASK} -ref ${LORES_BRAIN2} -out ${VOX_MASK_LO2} -applyxfm -init ${LO2LO2MAT}

if [ ${MASKLO} == 1 ]
then
	#get composition with mask onto pve lowres
	#pve_1 gives grey matter
	GREY_LO=`fslstats ${LORES_BRAIN1}_pve_1 -k ${VOX_MASK} -m -v`
	WHITE_LO=`fslstats ${LORES_BRAIN1}_pve_2 -k ${VOX_MASK} -m`
	CSF_LO=`fslstats ${LORES_BRAIN1}_pve_0 -k ${VOX_MASK} -m`
else
	LO_FILE=${BASEDIR}/cital2_analysis/structural/voxel_contents.txt
	GREY_LO=$( cat ${LO_FILE} | grep ^${SCANONE_NO} | awk '{print $2}' )
	WHITE_LO=$( cat ${LO_FILE} | grep ^${SCANONE_NO} | awk '{print $3}' )
	CSF_LO=$( cat ${LO_FILE} | grep ^${SCANONE_NO} | awk '{print $4}' )
fi

#calculate pve for hires structural brain if needed
if test ! -f ${HIRES_BRAIN}_pve_1.nii.gz
	then
	fast  -t1 -c 3 -n -e -ov ${HIRES_BRAIN}
fi
#get composition with mask onto pve hires
GREY_HI=`fslstats ${HIRES_BRAIN}_pve_1 -k ${VOX_MASK_HI} -m`
WHITE_HI=`fslstats ${HIRES_BRAIN}_pve_2 -k ${VOX_MASK_HI} -m`
CSF_HI=`fslstats ${HIRES_BRAIN}_pve_0 -k ${VOX_MASK_HI} -m`

#get composition with mask onto pve lores2
GREY_LO2=`fslstats ${LORES_BRAIN2}_pve_1 -k ${VOX_MASK_LO2} -m`
WHITE_LO2=`fslstats ${LORES_BRAIN2}_pve_2 -k ${VOX_MASK_LO2} -m`
CSF_LO2=`fslstats ${LORES_BRAIN2}_pve_0 -k ${VOX_MASK_LO2} -m`

echo ${SUBJ_NO} ${SCANONE_NO} ${WHITE_LO} ${CSF_LO} ${GREY_LO} hires ${WHITE_HI} ${CSF_HI} ${GREY_HI} ${SCANTWO_NO} ${WHITE_LO2} ${CSF_LO2} ${GREY_LO2} >>${OUTFILE}
