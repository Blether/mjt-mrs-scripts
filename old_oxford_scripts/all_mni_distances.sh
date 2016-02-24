#!/usr/local/bin/bash
# outputs distances between voxel centres in mni space
# for each subject in the trial specified as an argument

bdir=${HOME}/scratch/${1}_analysis
table=${bdir}/subject_scans.txt

cat ${table} | egrep '[0-9][0-9][0-9]$' |while read line
	do
	echo ${line}
	mnispace_distance.sh ${1} $(echo ${line} | gawk '{print $2 " " $3}')
	echo
	#echo ${1} $(echo ${line} | gawk '{print $2 " " $3}')
done

