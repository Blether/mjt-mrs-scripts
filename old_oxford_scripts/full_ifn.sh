#!/bin/bash
# do standard analyses for the IFN1 study
#
# Matt Taylor 2010-04-08

STUDY=ifn1
SCANNO=$1

WORKDIR=${HOME}/scratch/${STUDY}

# lcmodel - will not tolerate being put on the queues!
for RDA in press_front special_front press_rear special_rear lactate_ventricle lactate_tissue
do
 siemens_lcm.sh ${STUDY} ${SCANNO} ${RDA} nodc
done

for RDA in special_front special_rear lactate_ventricle lactate_tissue
do
 siemens_lcm.sh ${STUDY} ${SCANNO} ${RDA} dc
done


# structural bits
batch struc_analyses.sh ${STUDY} ${SCANNO}
