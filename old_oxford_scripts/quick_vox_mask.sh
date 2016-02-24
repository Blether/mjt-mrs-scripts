#!/usr/local/bin/bash
#
# quick script to get voxel mask and brain nii image from given filedetails
#
# matt taylor 2008-04-15
studyid=$1
scandir=/home/fs0/taylor/scratch/${studyid}
indiv=$2
indivshort=${2%%_*}
braindir=${scandir}
mrsfile=${scandir}/original_scans/${indiv}/${3}.fid
strucfile=${scandir}/original_scans/${indiv}/series_${4}.fid
strucnii=${scandir}/voxel_position/${indivshort}
outfile=${scandir}/voxel_position/${indivshort}.voxel
emptystruc=${scandir}/voxel_position/empty
maskfile=${scandir}/voxel_position/${indivshort}_voxel

/usr/local/fsl/bin/load_varian ${strucfile} ${strucnii} -ms -bl -ft3d -fermi -resl -rot -pss -mod -16 -niigz  

#/usr/local/fsl/bin/bet ${braindir}/${indivshort} ${braindir}/${indivshort}_brain -f 0.5 -g 0
#? include checks for presence of necessary files etc??

echo $indiv

	# MRS voxel position in cm from centre of scan.
positions=$(cat ${mrsfile}/procpar |egrep -A 1 '^pos1|^pos2|^pos3' |sed -n '2p;5p;8p' |gawk '{print $2}')
# pos1 pos3 pos2 is the order they come out...
pos1=$(echo $positions |gawk '{print $1}')
pos2=$(echo $positions |gawk '{print $3}')
pos3=$(echo $positions |gawk '{print $2}')

echo x=${pos2}
echo y=${pos1}
echo z=${pos3}
	# Structural scan position in cm
#this is not neat - it is finding both pss and pss0 although the output is correct...
	middle_slice_cm=`grep -A 1 ^pss ${strucfile}/procpar | gawk -F ' ' '{print $2}' | tail -n1`

	middle_slice_mm=`echo ${middle_slice_cm} / 0.1 | bc -l`
	

echo middle_slice=${middle_slice_mm}

	
	# find structural scan voxel size 
strucdims=$(fslinfo $strucnii |grep dim |gawk '{print $2}')
x_pixel=$(echo ${strucdims} | gawk '{print $5}')
y_pixel=$(echo ${strucdims} | gawk '{print $6}')
z_pixel=$(echo ${strucdims} | gawk '{print $7}')

echo x_pixel=${x_pixel}
echo y_pixel=${y_pixel}
echo z_pixel=${z_pixel}	

	# position of centre of MRS scan in voxels

x=$(echo ${strucdims} | gawk '{print $1}')
y=$(echo ${strucdims} | gawk '{print $2}')
z=$(echo ${strucdims} | gawk '{print $3}')

	x_pos=`echo $x / 2 | bc -l`
	y_pos=`echo $y / 2 | bc -l`
	z_pos_uncorr=`echo $z / 2 | bc -l`

echo scan size= $x $y $z

echo x_pos=${x_pos}
echo y_pos=${y_pos}
echo z_pos=${z_pos_uncorr}		
	# now find centre of MRS scan in cm.

	
	middle_slice_voxels=`echo ${middle_slice_mm} / ${z_pixel} | bc -l`
	z_pos=`echo ${z_pos_uncorr} + ${middle_slice_voxels} | bc -l` 
		
	# middle of MRS voxel in cm to middle in voxels

	pos_1_mm=`echo ${pos1} / 0.1 | bc -l`
	pos_2_mm=`echo ${pos2} / 0.1 | bc -l`
	pos_3_mm=`echo ${pos3} / 0.1 | bc -l`

	abs_x=`echo ${pos_2_mm} / ${x_pixel} | bc -l`
	abs_y=`echo ${pos_1_mm} / ${y_pixel} | bc -l`
	abs_z=`echo ${pos_3_mm} / ${z_pixel} | bc -l`

	x_corner=`echo ${x_pos} - ${abs_x} | bc -l`
	y_corner=`echo ${y_pos} - ${abs_y} | bc -l`
	z_corner=`echo ${z_pos} - ${abs_z} | bc -l`

echo relative_pos_of_voxel_x=${x_corner}		
echo relative_pos_of_voxel_y=${y_corner}
echo relative_pos_of_voxel_z=${z_corner}

	# Find size of MRS voxel in voxels.
voxels=$(cat ${mrsfile}/procpar |egrep -A 1 '^vox1|^vox2|^vox3' |sed -n '2p;5p;8p' |gawk '{print $2}')
# gives vox1 vox3 vox2
v1=$(echo $voxels |gawk '{print $1}')
v2=$(echo $voxels |gawk '{print $3}')
v3=$(echo $voxels |gawk '{print $2}')

	x_size=`echo ${v2} / ${x_pixel} | bc -l`
	y_size=`echo ${v1} / ${y_pixel} | bc -l`
	z_size=`echo ${v3} / ${z_pixel} | bc -l`
	
	# Find distance from middle of voxel to corner

	x_side=`echo $x_size / 2 | bc -l`
	y_side=`echo $y_size / 2 | bc -l`
	z_side=`echo $z_size / 2 | bc -l`


echo voxel size= ${x_size} ${y_size} ${z_size}
echo half voxel size = ${x_side} ${y_side} ${z_side}

	# find correct corner to start from.

	x_correct=`echo ${x_corner} - ${x_side} | bc -l`	
	y_correct=`echo ${y_corner} - ${y_side} | bc -l`
	z_correct=`echo ${z_corner} - ${z_side} | bc -l`


echo correct voxel corner = ${x_correct} ${y_correct} ${z_correct}
echo ${x_correct} ${y_correct} ${z_correct} >${outfile}
echo ${x_size} ${y_size} ${z_size} >>${outfile}
echo ---
makevoxelmask.sh ${outfile} ${emptystruc} ${maskfile}
