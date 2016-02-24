#!/usr/local/bin/bash
#
# script for processing my me_fmri data as per usual
#
# Matthew Taylor
# 2008-02-16
INFILE=$1
OUTFILE=$2

process_me_fmri -nWds ${INFILE}.fid m
if test -d img_${INFILE}
then
cd img_${INFILE}
avwmerge -a ${OUTFILE} mean_dc_${INFILE}_0*hdr
rbet ${OUTFILE} ${OUTFILE}_rbet -v -f 0.5 -m -n -c 150 50 250 -r 60 -x 1.4 -y 1.25 -z 3
avwchfiletype NIFTI_GZ ${OUTFILE}
avwchfiletype NIFTI_GZ ${OUTFILE}_rbet_mask
mv ${OUTFILE}* ../
fi
