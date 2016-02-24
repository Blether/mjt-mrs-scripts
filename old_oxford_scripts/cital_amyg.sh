#!/bin/bash
# get Amygdala masks with FIRST
# for cital2 study faces analysis
#
# mjt 2009-01-17

SUBJNO=$1
#STUDYDIR=${HOME}/Documents/cital_fmri
STUDYDIR=${HOME}/scratch/cital_fmri
OUTDIR=${STUDYDIR}/FIRST
REFSTRUC=${FSLDIR}/data/standard/MNI152_T1_1mm_brain.nii.gz

STRUCIMG=${STUDYDIR}/Archive/subject_${SUBJNO}

first_flirt ${STRUCIMG} ${OUTDIR}/${SUBJNO}_to_std_sub
echo check registration visually!
run_first -i ${STRUCIMG} -t ${OUTDIR}/${SUBJNO}_to_std_sub.mat -n 50 -o ${OUTDIR}/${SUBJNO}_L_Amyg -m ${FSLDIR}/data/first/models_336_bin/L_Amyg_bin.bmv
run_first -i ${STRUCIMG} -t ${OUTDIR}/${SUBJNO}_to_std_sub.mat -n 50 -o ${OUTDIR}/${SUBJNO}_R_Amyg -m ${FSLDIR}/data/first/models_336_bin/R_Amyg_bin.bmv

