#!/bin/bash
# variant of get_voxel.sh to work with siemens .rda spectroscopy
# also make the mask - not using .voxel file any more; seems less convenient
#
# Matt Taylor 2010-04
#
# example usage:
# batch get_voxel_from_rda.sh ifn1 NT07416 press_rear
#
# known issues:
# may not work (currently) if structural scan is not 1x1x1 mm dimensions
# may not work if voxel is not aligned to the three axes in the scanner - work in progress july 2010


STUDYID=$1
INDIV=$2
SUBDIR=$3

DO_ROTATE=$4

SCANDIR=${HOME}/scratch/${STUDYID}
MRS_RDA=${SCANDIR}/original_scans/${INDIV}/${SUBDIR}/*.rda
#MRS_RDA=${SCANDIR}/original_scans/${INDIV}/${SUBDIR}/*${SUBDIR}.rda
STRUCFILE=${SCANDIR}/original_scans/${INDIV}/images/${INDIV}/*anatomy*nii.gz
TEMPDIR=${SCANDIR}/struc/temp_${INDIV}_${SUBDIR}
EMPTYFILE=${SCANDIR}/struc/empty_struc
MATFILE=${TEMPDIR}/mat
OUTFILE=${SCANDIR}/struc/${INDIV}_${SUBDIR}_voxel

mkdir -p ${TEMPDIR}

# get voxel details from spectroscopy data - check axes correct
POS1=$(strings ${MRS_RDA} | egrep ^VOIPositionSag | cut -d ' ' -f2)
POS2=$(strings ${MRS_RDA} | egrep ^VOIPositionCor | cut -d ' ' -f2)
POS3=$(strings ${MRS_RDA} | egrep ^VOIPositionTra | cut -d ' ' -f2)
VOX3=$(strings ${MRS_RDA} | egrep ^VOIThickness | cut -d ' ' -f2)
VOX2=$(strings ${MRS_RDA} | egrep ^VOIPhaseFOV | cut -d ' ' -f2)
VOX1=$(strings ${MRS_RDA} | egrep ^VOIReadoutFOV | cut -d ' ' -f2)

echo ${INDIV} ${SUBDIR} ${POS1} ${POS2} ${POS3} ${VOX1} ${VOX2} ${VOX3}


# get voxel dimensions from structural image file - not using these currently as 1x1x1 data
VST1=$(fslinfo ${STRUCFILE} | egrep ^pixdim1 | cut -d ' ' -f9)
VST2=$(fslinfo ${STRUCFILE} | egrep ^pixdim2 | cut -d ' ' -f9)
VST3=$(fslinfo ${STRUCFILE} | egrep ^pixdim3 | cut -d ' ' -f9)

#ST_SIZE1=$(fslval ${STRUCFILE} dim1)
#ST_SIZE2=$(fslval ${STRUCFILE} dim2)
#ST_SIZE3=$(fslval ${STRUCFILE} dim3)

# need to get translation parameters from the struc too!
fslval ${STRUCFILE} sto_xyz:1  > ${MATFILE}_a
fslval ${STRUCFILE} sto_xyz:2  >> ${MATFILE}_a
fslval ${STRUCFILE} sto_xyz:3  >> ${MATFILE}_a
fslval ${STRUCFILE} sto_xyz:4  >> ${MATFILE}_a
convert_xfm -omat ${MATFILE}_a_i.mat -inverse ${MATFILE}_a

#make voxel mask and then move it around
fslmaths ${EMPTYFILE} -add 1 -roi 0 ${VOX1} 0 ${VOX2} 0 ${VOX3} 0 1 ${TEMPDIR}/vox_start

echo 1 0 0 $(echo -1*${POS1} - .5*${VOX1} |bc) > ${MATFILE}_shift.mat
echo 0 1 0 $(echo -1*${POS2} - .5*${VOX2} |bc) >> ${MATFILE}_shift.mat
echo 0 0 1 $(echo ${POS3} - .5*${VOX3} | bc) >> ${MATFILE}_shift.mat
echo 0 0 0 1 >> ${MATFILE}_shift.mat

convert_xfm -omat ${MATFILE}_total.mat -concat ${MATFILE}_a_i.mat ${MATFILE}_shift.mat

flirt -in ${TEMPDIR}/vox_start -ref ${STRUCFILE} -out ${OUTFILE} -applyxfm -init ${MATFILE}_total.mat

# need to incorporate correction for voxel angulation
if [ "$DO_ROTATE" = "1" ] ;
then
echo correcting for voxel angulation relative to structural scan
cd ${TEMPDIR} # let us create temp files freely
ln -s ${MRS_RDA} temp.rda
echo "rotmat_from_vectors('temp.rda', 'rotate.mat')" | matlab -nojvm -nosplash -nodisplay >/dev/null
mv ${OUTFILE}* ${TEMPDIR}/vox_norotate.nii.gz
convert_xfm -omat ${MATFILE}_rotate_i.mat -inverse rotate.mat
cat ${MATFILE}_rotate_i.mat
flirt -in ${TEMPDIR}/vox_norotate.nii.gz -ref ${STRUCFILE} -out ${OUTFILE} -applyxfm -init ${MATFILE}_rotate_i.mat

rm temp.rda

fi

#clean up
#rm -r ${TEMPDIR}

