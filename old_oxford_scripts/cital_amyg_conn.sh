#!/bin/bash
#
# do connectivity analysis of the faces data using a bilateral amygdala mask
# as seed region
#
# mjt 2009-02-22

SUBJNO=$1
WORKDIR=${HOME}/scratch/cital_fmri
OUTDIR=${WORKDIR}/amyg_correl/${SUBJNO}
FUNCDATA=${WORKDIR}/subj_${SUBJNO}_faces.feat/filtered_func_data.nii.gz
L_AMYGROI=${WORKDIR}/FIRST/${SUBJNO}_L_Amyg.nii.gz
R_AMYGROI=${WORKDIR}/FIRST/${SUBJNO}_R_Amyg.nii.gz
AMYG_TS=${OUTDIR}/${SUBJNO}_amyg_ts.txt
STRUCBRAIN=${WORKDIR}/Archive/subject_${SUBJNO}_structural.nii.gz
STRUC2FUNCMAT=${WORKDIR}/subj_${SUBJNO}_faces.feat/reg/highres2example_func.mat
STANDARDBRAIN=${FSLDIR}/data/standard/MNI152_T1_1mm_brain.nii.gz
MASTER_FSF=${WORKDIR}/amyg_correl/master_design.fsf

# prepare workspace
mkdir -p ${OUTDIR}
cd ${OUTDIR}
#create bilater amygdala mask in functional space
fslmaths ${L_AMYGROI} -add ${R_AMYGROI} ${SUBJNO}_bil_amyg_ROI
flirt -in ${SUBJNO}_bil_amyg_ROI -out ${SUBJNO}_bil_amyg_ROI_funcspace -ref ${FUNCDATA} -applyxfm -init ${STRUC2FUNCMAT}
fslmaths ${SUBJNO}_bil_amyg_ROI_funcspace -bin ${SUBJNO}_bil_amyg_ROI_func_mask
#extract amygdala time series
fslmeants -i ${FUNCDATA} -m ${SUBJNO}_bil_amyg_ROI_func_mask -o ${AMYG_TS}
# create subject specific design.fsf
cat ${MASTER_FSF} |sed s#REGSTAND#${STANDARDBRAIN}# |\
sed s#OUTDIR#${OUTDIR}/${SUBJNO}_amyg_conn.feat# |\
sed s#STRUCBRAIN#${STRUCBRAIN}# |\
sed s#TS_FILE#${AMYG_TS}# |\
sed s#FUNCDATA#${FUNCDATA}# > ${OUTDIR}/design.fsf
# run feat
#feat design.fsf
