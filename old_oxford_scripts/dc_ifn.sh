#!/bin/bash
# process drift corrected data with lcmodel
# interferon study

SCANNO=$1

# ?test for presence of correct data
# tk - need to ensure naming convention consistent

# lcmodel - will not tolerate being put on the queues!
for RDA in special_front special_rear lactate_ventricle lactate_tissue
do
 siemens_lcm.sh ifn1 ${SCANNO} ${RDA} dc
done
