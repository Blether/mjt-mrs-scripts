#!/bin/bash
# run featquery for the cital2 study faces data
# using amygdala masks generated using FIRST
#
# mjt 2009-01-20

SUBJNO=$1
WORKDIR=${HOME}/scratch/cital_fmri

FEATDIR=${WORKDIR}/subj_${SUBJNO}_faces.feat
LMASKDIR=${WORKDIR}/FIRST/${SUBJNO}_L_Amyg
RMASKDIR=${WORKDIR}/FIRST/${SUBJNO}_R_Amyg
LOUTDIR=L_amyg_featquery_pe1_pe3
ROUTDIR=R_amyg_featquery_pe1_pe3

featquery 1 ${FEATDIR} 2 stats/pe1 stats/pe3 ${LOUTDIR} -p ${LMASKDIR}
featquery 1 ${FEATDIR} 2 stats/pe1 stats/pe3 ${ROUTDIR} -p ${RMASKDIR}

echo ${SUBJNO}
cat ${FEATDIR}/${LOUTDIR}/report.txt | gawk '{print "l " $2 " " $7}'
cat ${FEATDIR}/${ROUTDIR}/report.txt | gawk '{print "r " $2 " " $7}'
