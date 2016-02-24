#!/bin/bash
#
# takes .voxel file and produces a voxelmask in same
# dimensions etc as structural scan
#
# Matthew Taylor 15-08-2007
#
#NB - need to think how to make this work where not aligned
# to scanner i.e. phi psi or theta non-zero
# mjt 2008-04
voxelfile=$1
struc_file=$2
# this is an empty file with appropriate dimensions etc
# produced with fslcreatehd
# e.g. empty_strucfile in ../cital2_analysis/structural/
outfile=$3
if [ "$2" == "" ] ;
then
struc_file='empty_struc'
outfile=${voxelfile%%.*}_voxel
fi

# make use of the .voxel files produced by get_voxel.sh
# these provide xcorrect ycorrect zcorrect \n xsize ysize zsize
voxparams=$(cat ${voxelfile})
x_correct=$(echo ${voxparams} |gawk '{printf "%.0f\n", $1}')
y_correct=$(echo ${voxparams} |gawk '{printf "%.0f\n", $2}')
z_correct=$(echo ${voxparams} |gawk '{printf "%.0f\n", $3}')
x_size=$(echo ${voxparams} |gawk '{printf "%.0f\n", $4}')
y_size=$(echo ${voxparams} |gawk '{printf "%.0f\n", $5}')
z_size=$(echo ${voxparams} |gawk '{printf "%.0f\n", $6}')

fslmaths ${struc_file} -add 1 -roi ${x_correct} ${x_size} ${y_correct} ${y_size} ${z_correct} ${z_size} 0 1 ${outfile}
