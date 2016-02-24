#!/usr/local/bin/bash
# this calculates the distance between two points in 3D space
# takes as arguments
# study shortscanid1 shortscanid2

strucdir=${HOME}/scratch/${1}_analysis/structural
mnivoxels=${strucdir}/voxels_mnispace.txt

mnicentres=$(egrep "^${2}|^${3}" ${mnivoxels})
echo ${mnicentres}

#xdif=$(echo $1 - $4| bc -l)
#ydif=$(echo $2 - $5| bc -l)
#zdif=$(echo $3 - $6| bc -l)
xdif=$(echo ${mnicentres} |gawk '{print $6 - $2}')
ydif=$(echo ${mnicentres} |gawk '{print $7 - $3}')
zdif=$(echo ${mnicentres} |gawk '{print $8 - $4}')
echo "sqrt((${xdif}^2) + (${ydif}^2) + (${zdif}^2))" |bc -l
