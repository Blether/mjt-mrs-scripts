#!/bin/bash
#
# extracts brain etc, puts it in the correct place
# the various commandline parameters are from running the gui with defaults
# so nothing too unusual probably
#
# mjt 2007-04

studyid=$1
file=$2
shortfile=${file%%_*}
basedir=/vols/Scratch/taylor/${studyid}_analysis
#mnibrain=/usr/local/fsl/data/standard/avg152T1_brain.hdr
mnibrain=/usr/local/fsl/data/standard/MNI152_T1_1mm_brain
if [ "$3" == "" ] ;
then
varianscan=${basedir}/original_scans/${file}/series_3.1
else
varianscan=${basedir}/original_scans/${file}/series_${3}
fi
braindir=${basedir}/structural/brains

#echo $file $shortfile $basedir $varianscan $braindir

/usr/local/fsl/bin/load_varian ${varianscan} ${braindir}/${shortfile} -ms -bl -ft3d -fermi -resl -rot -pss -mod -16 -niigz  
#/usr/local/fsl/bin/runfsl  -t 15 /usr/local/fsl/bin/load_varian ${varianscan} ${braindir}/${shortfile} -ms -bl -ft3d -fermi -resl -rot -pss -mod -16 -niigz  

/usr/local/fsl/bin/bet ${braindir}/${shortfile} ${braindir}/${shortfile}_brain -f 0.5 -g 0

/usr/local/fsl/bin/flirt -in ${braindir}/${shortfile}_brain.nii.gz -ref ${mnibrain} -out ${braindir}/${shortfile}_brain_mni.nii.gz -omat ${braindir}/${shortfile}_brain_mni.mat -bins 256 -cost corratio -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 12  -interp trilinear

