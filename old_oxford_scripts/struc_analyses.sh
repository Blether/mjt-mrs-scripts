#!/bin/bash
#
# structural bits that will tolerate being put on the queues
# would be good to have better handling of the sequence list
# Matt Taylor 2010-04-08


STUDY=$1
SCANNO=$2

extract_brain.sh ${STUDY} ${SCANNO} && for RDA in press_front press_rear lactate_ventricle lactate_tissue
do
get_voxel_from_rda.sh ${STUDY} ${SCANNO} ${RDA}
get_vox_contents.sh ${STUDY} ${SCANNO} ${SCANNO}_${RDA}_voxel
voxel_2_mnispace.sh ${STUDY} ${SCANNO} ${SCANNO}_${RDA}_voxel
done

