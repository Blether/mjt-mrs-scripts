#!/bin/bash
# script to analyse cital2 study faces functional data
# tell it the subject to analyse
# and which version of faces was used

SUBJNO=$1
VERSION=$2

#STUDYDIR=${HOME}/Documents/cital_fmri
STUDYDIR=${HOME}/scratch/cital_fmri
FSF_MASTER1=${STUDYDIR}/fsf_files/faces_v1.fsf
FSF_MASTER2=${STUDYDIR}/fsf_files/faces_v2.fsf

if [ ${VERSION} == "1" ];
then
echo using version 1
FSF_MASTER=${FSF_MASTER1}
else
echo using version 2
FSF_MASTER=${FSF_MASTER2}
fi


OUTDIR=${STUDYDIR}/subj_${SUBJNO}_faces.feat
FUNC_DATA=${STUDYDIR}/Archive/subject_${SUBJNO}_faces.nii.gz
REFSTRUC=${FSLDIR}/data/standard/MNI152_T1_1mm_brain.nii.gz
STRUCIMG=${STUDYDIR}/Archive/subject_${SUBJNO}_structural.nii.gz
FSF_FILE=${STUDYDIR}/fsf_files/subj_${SUBJNO}_v${VERSION}_faces.fsf

# generate individualised .fsf file

cat ${FSF_MASTER} |  sed s#OUTDIR#${OUTDIR}# |\
sed s#REGSTAND#${REFSTRUC}# |\
sed s#FUNCDATA#${FUNC_DATA}# |\
sed s#STRUCIMG#${STRUCIMG}# > ${FSF_FILE}

#feat ${FSF_FILE}
