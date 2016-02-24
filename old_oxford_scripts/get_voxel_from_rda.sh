#!/bin/bash
#This script creates a voxel mask image that can be used to 
#determine the tissue components within an MRS voxel.  
#

# Jamie Near 02/08/2010
# Developed with a great deal of help of Mark Jenkinson
# Using some bits of code from Matt Taylor (get_voxel_from_rda.sh)

# Jamie Near 16/08/2010
# Modified the code to accept structural images with arbitrary
# voxel dimensions.

# Matt Taylor's original code was not designed to handle MRS voxels that 
# are tilted with respect to the scanner coordinate space.
# This code has been modified to handle MRS voxels that are tilted
# in any orientation


STUDYID=$1
INDIV=$2
SUBDIR=$3

SCANDIR=${HOME}/scratch/${STUDYID}
MRS_RDA=${SCANDIR}/original_scans/${INDIV}/${SUBDIR}/*.rda
STRUCFILE=${SCANDIR}/original_scans/${INDIV}/images/${INDIV}/*anatomy*nii.gz
TEMPDIR=${SCANDIR}/struc/temp_${INDIV}_${SUBDIR}
EMPTYFILE=${SCANDIR}/struc/empty_struc
MATFILE=${TEMPDIR}/mat
OUTFILE=${SCANDIR}/struc/${INDIV}_${SUBDIR}_voxel

mkdir -p ${TEMPDIR}

# get voxel information from .rda file:
POS1=$(strings ${MRS_RDA} | egrep ^VOIPositionSag | cut -d ' ' -f2)
POS2=$(strings ${MRS_RDA} | egrep ^VOIPositionCor | cut -d ' ' -f2)
POS3=$(strings ${MRS_RDA} | egrep ^VOIPositionTra | cut -d ' ' -f2)
VOX1=$(strings ${MRS_RDA} | egrep ^FoVWidth | cut -d ' ' -f2)
VOX2=$(strings ${MRS_RDA} | egrep ^FoVHeight | cut -d ' ' -f2)
VOX3=$(strings ${MRS_RDA} | egrep ^SliceThickness | cut -d ' ' -f2)
ROW1=$(strings ${MRS_RDA} | egrep ^RowVector.0 | cut -d ' ' -f2)
ROW2=$(strings ${MRS_RDA} | egrep ^RowVector.1 | cut -d ' ' -f2)
ROW3=$(strings ${MRS_RDA} | egrep ^RowVector.2 | cut -d ' ' -f2)
COL1=$(strings ${MRS_RDA} | egrep ^ColumnVector.0 | cut -d ' ' -f2)
COL2=$(strings ${MRS_RDA} | egrep ^ColumnVector.1 | cut -d ' ' -f2)
COL3=$(strings ${MRS_RDA} | egrep ^ColumnVector.2 | cut -d ' ' -f2)

# Print the values that were found
echo ${INDIV} ${SUBDIR}
echo $POS1 $POS2 $POS3
echo $VOX1 $VOX2 $VOX3
echo $ROW1 $ROW2 $ROW3
echo $COL1 $COL2 $COL3

# Get the voxel dimensions of the structural image, as we may need these 
# in the future
VST1=$(fslinfo ${STRUCFILE} | egrep ^pixdim1 | cut -d ' ' -f9)
VST2=$(fslinfo ${STRUCFILE} | egrep ^pixdim2 | cut -d ' ' -f9)
VST3=$(fslinfo ${STRUCFILE} | egrep ^pixdim3 | cut -d ' ' -f9)

# Change the sign of the x- and y-coordinates on the **ASSUMPTION** that 
# the nifti version of the scanner coordinates and the spectroscopy version
# of the scanner coordinates are related by x -> -x, y -> -y, z -> z

POS1=`echo "$POS1 * -1.0" | bc -l`
POS2=`echo "$POS2 * -1.0" | bc -l`
ROW1=`echo "$ROW1 * -1.0" | bc -l`
ROW2=`echo "$ROW2 * -1.0" | bc -l`
COL1=`echo "$COL1 * -1.0" | bc -l`
COL2=`echo "$COL2 * -1.0" | bc -l`

# Now, divide POS1,2,3, and VOX1,2,3 by the voxel dimensions of the structural.  
# This should account for the voxel dimensions of the structural image. 16/08/2010.

POS1=`echo "$POS1 / $VST1" | bc -l`
POS2=`echo "$POS2 / $VST2" | bc -l`
POS3=`echo "$POS3 / $VST3" | bc -l`
VOX1=`echo "$VOX1 / $VST1" | bc -l`
VOX2=`echo "$VOX2 / $VST2" | bc -l`
VOX3=`echo "$VOX3 / $VST3" | bc -l`

# While ROW and COL specify two of the axes of the voxel orientation in
# scanner space, we still need a vector to specify the third axis.  We
# will obtain this by performing a cross product of ROW and COL, and we 
# will call the resulting vector ZED

ZED1=`echo "($COL2 * $ROW3) - ($COL3 * $ROW2)" |bc`
ZED2=`echo "($COL3 * $ROW1) - ($COL1 * $ROW3)" |bc`
ZED3=`echo "($COL1 * $ROW2) - ($COL2 * $ROW1)" |bc`

# Get the transformation from the structural image coordinate space (st)
# into the scanner coordinate space (sc)
fslval ${STRUCFILE} sto_xyz:1 > ${MATFILE}_st2sc
fslval ${STRUCFILE} sto_xyz:2 >> ${MATFILE}_st2sc
fslval ${STRUCFILE} sto_xyz:3 >> ${MATFILE}_st2sc
fslval ${STRUCFILE} sto_xyz:4 >> ${MATFILE}_st2sc

# We will need the inverse of this matrix:
convert_xfm -omat ${MATFILE}_sc2st -inverse ${MATFILE}_st2sc

# Now we are ready to make the initial mask.  Start by puting it in the 
# bottom corner of the image.  Only the size will be correct.
fslmaths ${STRUCFILE} -mul 0 -add 1 -roi 0 ${VOX1} 0 ${VOX2} 0 ${VOX3} 0 1 ${TEMPDIR}_vox_start


# Okay, now we need to make a rotation matrix to rotate from the spectroscopy
# voxel coordinate space (sp), into the scanner coordinate space (sc)
echo $(echo ${ROW1} ${COL1} ${ZED1}) 0 > ${MATFILE}_sp2sc_R
echo $(echo ${ROW2} ${COL2} ${ZED2}) 0 >> ${MATFILE}_sp2sc_R
echo $(echo ${ROW3} ${COL3} ${ZED3}) 0 >> ${MATFILE}_sp2sc_R
echo 0 0 0 1 >> ${MATFILE}_sp2sc_R

# Now we need to make two translation matrices to translate from the spectroscopy
# voxel coordinate space, into the scanner coordinate space:
# The first translates by the voxel centre position in scanner space
echo 0 0 0 $(echo ${POS1})> ${MATFILE}_sc_Tc
echo 0 0 0 $(echo ${POS2})>> ${MATFILE}_sc_Tc
echo 0 0 0 $(echo ${POS3})>> ${MATFILE}_sc_Tc
echo 0 0 0 0 >> ${MATFILE}_sc_Tc

# And the second translates back by half of the voxel dimensions.
echo 1 0 0 $(echo -.5*${VOX1} | bc)> ${MATFILE}_sc_Tv
echo 0 1 0 $(echo -.5*${VOX2} | bc)>> ${MATFILE}_sc_Tv
echo 0 0 1 $(echo -.5*${VOX3} | bc)>> ${MATFILE}_sc_Tv
echo 0 0 0 1 >> ${MATFILE}_sc_Tv

# Next, we must concatenate sc2st with sc_Tc to make a new matrix, 
# which we will call:  st_Tc

convert_xfm -omat ${MATFILE}_st_Tc -concat ${MATFILE}_sc2st ${MATFILE}_sc_Tc

# Now we have all of the matrices that we need.  All we have to do now is 
# put them together by concatenating (as well as a bit of tricky manipulation
# as you will soon see).

# We need to make a matrix that contains the 4x4 identity matrix combined with 
# the last column of the st_Tc matrix.  We will call the resulting matrix 
# Id_st_Tc.  This is where the tricky manipulation happens:
col4=`cat ${MATFILE}_st_Tc | awk '{ print $4 }'`
t1=`echo $col4 | cut -d' ' -f1`
t2=`echo $col4 | cut -d' ' -f2`
t3=`echo $col4 | cut -d' ' -f3`

echo 1 0 0 $t1 > ${MATFILE}_Id_st_Tc
echo 0 1 0 $t2 >> ${MATFILE}_Id_st_Tc
echo 0 0 1 $t3 >> ${MATFILE}_Id_st_Tc
echo 0 0 0 1 >> ${MATFILE}_Id_st_Tc


# Now we just need to do some contatenations:
convert_xfm -omat ${MATFILE}_sp2st_R -concat ${MATFILE}_sc2st ${MATFILE}_sp2sc_R
convert_xfm -omat ${MATFILE}_sp2st_Tv_R -concat ${MATFILE}_sp2st_R ${MATFILE}_sc_Tv
convert_xfm -omat ${MATFILE}_final -concat ${MATFILE}_Id_st_Tc ${MATFILE}_sp2st_Tv_R

flirt -in ${TEMPDIR}_vox_start -ref ${STRUCFILE} -out ${OUTFILE} -applyxfm -init ${MATFILE}_final -interp nearestneighbour

#fslview ${STRUCFILE} ${OUTFILE}

#clean up
rm -r ${TEMPDIR}


