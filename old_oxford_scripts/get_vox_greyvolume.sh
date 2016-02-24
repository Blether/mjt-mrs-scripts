#!/usr/local/bin/bash
# script to calculate grey matter volume in voxel
# derived from one received from Charlie Stagg
# mjt 2007-03-22

echo why not measure all constituents?
dir=/home/fs0/taylor/scratch/${1}_analysis/structural
fileid=${2%%_*}
#fileid=${2}
outfile=${dir}/voxel_greymattervolumes.txt

# structural image is from press_3.1.fid
# voxel is from press26_64.fid
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
if test ! -f ${dir}/brains/${fileid}_brain_pve_1.nii.gz
then
	fast -ov ${dir}/brains/${fileid}_brain
	rm -f ${dir}/brains/${fileid}_brain_pve_0.nii.gz
	rm -f ${dir}/brains/${fileid}_brain_pve_2.nii.gz
fi
fslroi ${dir}/brains/${fileid}_brain_pve_1 ${dir}/voxel_grey ${x_correct} ${x_size} ${y_correct} ${y_size} ${z_correct} ${z_size}
grey_percent=`fslstats ${dir}/voxel_grey -m -v | gawk -F ' ' '{print $1}'`
total_volume=`fslstats ${dir}/voxel_grey -m -v | gawk -F ' ' '{print $3}'`
volume_of_grey=`echo ${grey_percent}*${total_volume} | bc` 
echo grey_percent = ${grey_percent}
echo total_vol = ${total_volume}
echo volume of grey = ${volume_of_grey}
echo ${fileid} ${volume_of_grey} >> ${outfile}
rm -f ${dir}/voxel_grey.nii.gz
