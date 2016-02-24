#!/usr/local/bin/bash
#
# this script generates the affine matrix to transform one _voxel image into the same
# space as another _voxel image..
#
# need to have calculated the transformation between real iamges
# and also have .voxel and _voxel.nii.gz files already
#
# $1 studyid
# $2 indiv_to i.e. scan one
# $3 indiv_from i.e. scan two
#
# Matt Taylor 2007-10-04

BASEDIR='/home/fs0/taylor/scratch'
STUDYDIR=${BASEDIR}/${1}_analysis/structural
TMPDIR=${STUDYDIR}/tmp
BRAINDIR=${STUDYDIR}/brains

if ! test -d ${TMPDIR}
then
	mkdir ${TMPDIR}

fi

FROMID=${3}
TOID=${2}

VOXSCALE='0.5'
# 0.5 equivalent to 2mm voxel (reciprocal)



#matrix from_voxel to real from_space

FROMREALCORNER=`cat ${STUDYDIR}/${FROMID}.voxel`
FROMVOXCORNER=`fslstats ${STUDYDIR}/${FROMID}_voxel -w`

FROM_X_REAL=`echo ${FROMREALCORNER} | gawk '{print $1}'`
FROM_Y_REAL=`echo ${FROMREALCORNER} | gawk '{print $2}'`
FROM_Z_REAL=`echo ${FROMREALCORNER} | gawk '{print $3}'`

FROM_X_VOX=`echo ${FROMVOXCORNER} | gawk '{print $1}'`
FROM_Y_VOX=`echo ${FROMVOXCORNER} | gawk '{print $3}'`
FROM_Z_VOX=`echo ${FROMVOXCORNER} | gawk '{print $5}'`

FROM_X_DELTA=`echo ${FROM_X_REAL} - ${FROM_X_VOX} | bc -l`
FROM_Y_DELTA=`echo ${FROM_Y_REAL} - ${FROM_Y_VOX} | bc -l`
FROM_Z_DELTA=`echo ${FROM_Z_REAL} - ${FROM_Z_VOX} | bc -l`

FROM_X_DELTA=`echo ${FROM_X_DELTA} / ${VOXSCALE} | bc -l`
FROM_Y_DELTA=`echo ${FROM_Y_DELTA} / ${VOXSCALE} | bc -l`
FROM_Z_DELTA=`echo ${FROM_Z_DELTA} / ${VOXSCALE} | bc -l`

echo 1 0 0 ${FROM_X_DELTA} > ${TMPDIR}/${FROMID}_voxtoreal.mat
echo 0 1 0 ${FROM_Y_DELTA} >> ${TMPDIR}/${FROMID}_voxtoreal.mat
echo 0 0 1 ${FROM_Z_DELTA} >> ${TMPDIR}/${FROMID}_voxtoreal.mat
echo 0 0 0 1 >> ${TMPDIR}/${FROMID}_voxtoreal.mat

#echo ${FROM_X_DELTA} ${FROM_Y_DELTA} ${FROM_Z_DELTA}
#echo ${FROM_X_VOX} ${FROM_Y_VOX} ${FROM_Z_VOX}
#echo ${FROM_X_REAL} ${FROM_Y_REAL} ${FROM_Z_REAL}

# matrix from _voxel to real to_space
TOREALCORNER=`cat ${STUDYDIR}/${TOID}.voxel`
TOVOXCORNER=`fslstats ${STUDYDIR}/${TOID}_voxel -w`

TO_X_REAL=`echo ${TOREALCORNER} | gawk '{print $1}'`
TO_Y_REAL=`echo ${TOREALCORNER} | gawk '{print $2}'`
TO_Z_REAL=`echo ${TOREALCORNER} | gawk '{print $3}'`

TO_X_VOX=`echo ${TOVOXCORNER} | gawk '{print $1}'`
TO_Y_VOX=`echo ${TOVOXCORNER} | gawk '{print $3}'`
TO_Z_VOX=`echo ${TOVOXCORNER} | gawk '{print $5}'`

TO_X_DELTA=`echo ${TO_X_REAL} - ${TO_X_VOX} | bc -l`
TO_Y_DELTA=`echo ${TO_Y_REAL} - ${TO_Y_VOX} | bc -l`
TO_Z_DELTA=`echo ${TO_Z_REAL} - ${TO_Z_VOX} | bc -l`

TO_X_DELTA=`echo ${TO_X_DELTA} / ${VOXSCALE} | bc -l`
TO_Y_DELTA=`echo ${TO_Y_DELTA} / ${VOXSCALE} | bc -l`
TO_Z_DELTA=`echo ${TO_Z_DELTA} / ${VOXSCALE} | bc -l`

echo 1 0 0 ${TO_X_DELTA} > ${TMPDIR}/${TOID}_voxtoreal.mat
echo 0 1 0 ${TO_Y_DELTA} >> ${TMPDIR}/${TOID}_voxtoreal.mat
echo 0 0 1 ${TO_Z_DELTA} >> ${TMPDIR}/${TOID}_voxtoreal.mat
echo 0 0 0 1 >> ${TMPDIR}/${TOID}_voxtoreal.mat

#get matrix for to _realtovox
convert_xfm -omat ${TMPDIR}/${TOID}_realtovox.mat -inverse ${TMPDIR}/${TOID}_voxtoreal.mat

# get matrix for realspace to realspace
if ! test -f ${STUDYDIR}/${FROMID}_to_${TOID}_6dof.mat
then
	flirt -dof 6 -in ${BRAINDIR}/${FROMID}_brain -ref ${BRAINDIR}/${TOID}_brain -omat ${STUDYDIR}/${FROMID}_to_${TOID}_6dof.mat
fi

# concatenate matrices...
convert_xfm -omat ${TMPDIR}/${FROMID}_vox_to_${TOID}.mat -concat ${STUDYDIR}/${FROMID}_to_${TOID}_6dof.mat ${TMPDIR}/${FROMID}_voxtoreal.mat

convert_xfm -omat ${STUDYDIR}/${FROMID}_vox_to_${TOID}_vox.mat -concat ${TMPDIR}/${TOID}_realtovox.mat ${TMPDIR}/${FROMID}_vox_to_${TOID}.mat




