#!/bin/bash
# script to calculate constituents in voxel
# derived from one received from Charlie Stagg
# mjt 2007-03-22
# changes to do all three components not just gm
# Matthew Taylor 2007-08-16
#
# version 2 - works with siemens files now
# Matt 2008-04-08

dir=/home/fs0/taylor/scratch/${1}_analysis/structural
fileid=${2%%_*}
#fileid=${2}
outfile=${dir}/voxel_contents.txt

# make use of the .voxel files produced by get_voxel.sh
# these provide xcorrect ycorrect zcorrect \n xsize ysize zsize
voxparams=$(cat ${dir}/${fileid}.voxel)
x_correct=$(echo ${voxparams} |gawk '{printf "%.0f\n", $1}')
y_correct=$(echo ${voxparams} |gawk '{printf "%.0f\n", $2}')
z_correct=$(echo ${voxparams} |gawk '{printf "%.0f\n", $3}')
x_size=$(echo ${voxparams} |gawk '{printf "%.0f\n", $4}')
y_size=$(echo ${voxparams} |gawk '{printf "%.0f\n", $5}')
z_size=$(echo ${voxparams} |gawk '{printf "%.0f\n", $6}')
#echo $y_correct $y_size
# segment image if required
if test ! -f ${dir}/brains/${fileid}_brain_pve_2.nii.gz
then
#partial volume segmentation
	#fast  -t1 -c 3 -n -e -ov ${dir}/brains/${fileid}_brain
	echo partial volume segmentation in process, ${fileid}
	fast  -t 1 -n 3 ${dir}/brains/${fileid}_brain
fi
fslroi ${dir}/brains/${fileid}_brain_pve_1 ${dir}/voxel_grey ${x_correct} ${x_size} ${y_correct} ${y_size} ${z_correct} ${z_size}
fslroi ${dir}/brains/${fileid}_brain_pve_0 ${dir}/voxel_csf ${x_correct} ${x_size} ${y_correct} ${y_size} ${z_correct} ${z_size}
fslroi ${dir}/brains/${fileid}_brain_pve_2 ${dir}/voxel_white ${x_correct} ${x_size} ${y_correct} ${y_size} ${z_correct} ${z_size}
grey_percent=`fslstats ${dir}/voxel_grey -m -v | gawk -F ' ' '{print $1}'`
total_volume=`fslstats ${dir}/voxel_grey -m -v | gawk -F ' ' '{print $3}'`
volume_of_grey=`echo ${grey_percent}*${total_volume} | bc` 
white_percent=`fslstats ${dir}/voxel_white -m`
csf_percent=`fslstats ${dir}/voxel_csf -m`
echo grey_percent = ${grey_percent}
echo total_vol = ${total_volume}
echo volume of grey = ${volume_of_grey}
echo white_percent = ${white_percent}
echo csf_percent = ${csf_percent}
echo ${fileid} ${grey_percent} ${white_percent} ${csf_percent} ${total_volume} >> ${outfile}
rm -f ${dir}/voxel_grey.nii.gz
rm -f ${dir}/voxel_csf.nii.gz
rm -f ${dir}/voxel_white.nii.gz
