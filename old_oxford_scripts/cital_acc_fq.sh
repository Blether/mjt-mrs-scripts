#!/bin/bash
#
# does featqueries for anterior cingulate cortex for cital2 fmri data
#
# mjt 2009-01-30

SUBJNO=$1
WORKDIR=${HOME}/scratch/cital_fmri

FEATDIR=${WORKDIR}/subj_${SUBJNO}_faces.feat
MAINVOXMASKDIR=${WORKDIR}/ACC_VOX/medianvoxelmask
SUBJVOXMASKDIR=${WORKDIR}/ACC_VOX/${SUBJNO}_scan2_mnivoxel
LOUTDIR=mainvox_featquery_pe1_pe3
ROUTDIR=subjvox_featquery_pe1_pe3
OUTFILE=${WORKDIR}/cital_acc_fq_summary.csv

featquery 1 ${FEATDIR} 2 stats/pe1 stats/pe3 ${LOUTDIR} -p ${MAINVOXMASKDIR}
featquery 1 ${FEATDIR} 2 stats/pe1 stats/pe3 ${ROUTDIR} -p ${SUBJVOXMASKDIR}

#extract the median mean and max values
L_OUT=`cat ${FEATDIR}/${LOUTDIR}/report.txt |gawk '{print $6 "," $7 "," $9}'`
R_OUT=`cat ${FEATDIR}/${ROUTDIR}/report.txt |gawk '{print $6 "," $7 "," $9}'`

echo ${SUBJNO}, ${L_OUT}, ${R_OUT} >>${OUTFILE}
