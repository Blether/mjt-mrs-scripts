#!/bin/bash
# teav_prepro.bash
# script to organise preprocessing of the te-averaged PRESS-J
# scans
#
# needs:
# teav.txt	jmrui txt format
# NO - now needs RAW	as produced by varian2raw (from LCMOdel)
# phases.dlm	zero-order phases to apply to each fid
#
# produces:
# teav_p.dlm	zero-order phases applied
# teav_ps.txt	phases applied and summed to yield single fid
#
# mjt 2007-01-31

#check for everything needed
#if test ! -f teav.txt || test ! -f phases.dlm;
if test ! -f RAWnh && test -f RAW
then
	raw2rawnh.sh
fi
if test ! -f RAWnh || test ! -f phases.dlm;
then
	echo 'Either no datafile or no phases.dlm  found in current directory'
else
	echo 'Files found, running matlab'
	if test -f teav_p.dlm
	then
	mv teav_p.dlm old_teav_p.dlm
	fi
	batch -q short.q matlab -nojvm -nosplash -nodisplay \< ~/matlab/teav16_prepro.m
	#matlab -nojvm -nosplash -nodisplay \< teav16_prepro.m
fi

