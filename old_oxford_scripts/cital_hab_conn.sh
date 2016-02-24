#!/bin/bash
#
# do connectivity analysis of the faces data using a bilateral amygdala mask
# as seed region
#
# mjt 2009-02-22

SUBJNO=$1
WORKDIR=${HOME}/scratch/cital_fmri
OUTDIR=${WORKDIR}/haben_correl/${SUBJNO}
FUNCDATA=${WORKDIR}/subj_${SUBJNO}_faces.feat/filtered_func_data.nii.gz
HAB_ROI=${WORKDIR}/haben_correl/habs_mask
HAB_ROI_SUBJ=${OUTDIR}/${SUBJNO}_hab_ROI
AMYG_TS=${OUTDIR}/${SUBJNO}_hab_ts.txt
STRUCBRAIN=${WORKDIR}/Archive/subject_${SUBJNO}_structural.nii.gz
STAND2FUNCMAT=${WORKDIR}/subj_${SUBJNO}_faces.feat/reg/standard2example_func.mat
STANDARDBRAIN=${FSLDIR}/data/standard/MNI152_T1_1mm_brain.nii.gz
MASTER_FSF=${WORKDIR}/haben_correl/master_design.fsf

# prepare workspace
mkdir -p ${OUTDIR}
cd ${OUTDIR}
#create mask in functional space
flirt -in ${HAB_ROI} -ref ${FUNCDATA} -out ${HAB_ROI_SUBJ} -applyxfm -init ${STAND2FUNCMAT}
fslmaths ${HAB_ROI_SUBJ} -bin ${HAB_ROI_SUBJ}_mask
#extract time series
fslmeants -i ${FUNCDATA} -m ${HAB_ROI_SUBJ}_mask -o ${AMYG_TS}
# create subject specific design.fsf
cat ${MASTER_FSF} |sed s#REGSTAND#${STANDARDBRAIN}# |\
sed s#OUTDIR#${OUTDIR}/${SUBJNO}_haben_correl.feat# |\
sed s#STRUCBRAIN#${STRUCBRAIN}# |\
sed s#TS_FILE#${AMYG_TS}# |\
sed s#FUNCDATA#${FUNCDATA}# > ${OUTDIR}/design.fsf
# run feat
#feat design.fsf
