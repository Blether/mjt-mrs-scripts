#!/bin/bash
# produce output summary for feqtquery results

SUBJNO=$1
WORKDIR=${HOME}/scratch/cital_fmri
FEATDIR=${WORKDIR}/subj_${SUBJNO}_faces.feat
LMASKDIR=${WORKDIR}/FIRST/${SUBJNO}_L_Amyg
RMASKDIR=${WORKDIR}/FIRST/${SUBJNO}_R_Amyg
LOUTDIR=L_amyg_featquery_pe1_pe3 
ROUTDIR=R_amyg_featquery_pe1_pe3 
OUTFILE=${WORKDIR}/cital_amyg_fq_summary.txt

#extract the median values
L_OUT=`cat ${FEATDIR}/${LOUTDIR}/report.txt |gawk '{print $6 " " $7 " " $9}'`
R_OUT=`cat ${FEATDIR}/${ROUTDIR}/report.txt |gawk '{print $6 " " $7 " " $9}'`

echo ${SUBJNO} ${L_OUT} ${R_OUT} >>${OUTFILE}
