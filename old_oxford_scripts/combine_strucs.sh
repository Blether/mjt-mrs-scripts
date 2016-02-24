#!/usr/local/bin/bash
#
# process the four structural images with Andrew Lowe's process_fse_t2
# correct for differences in scaling
# combine the images
# correct the voxel scale factors
# make rough mask with rbet (the Dave Lythgoe - IOP - version using spheroid rather than sphere)
#
# runs at physiology, so uses old fslutils (avwutils)
# Matthew Taylor 2008-01-30

#check enough inputs given


IMONE=$1
IMTWO=$2
IMTHREE=$3
IMFOUR=$4
IMOUT=$5

process_fse_t2 ${IMONE} 2> fse_t2_errors.log
SCALEONE=` cat fse_t2_errors.log | grep sisco2unc | tail -n 1 | sed "s/\'//g" | awk '{printf "%.0d\n", $NF}' `
process_fse_t2 ${IMTWO} 2> fse_t2_errors.log
SCALETWO=` cat fse_t2_errors.log | grep sisco2unc | tail -n 1 | sed "s/\'//g" | awk '{printf "%.0d\n", $NF}' `
process_fse_t2 ${IMTHREE} 2> fse_t2_errors.log
SCALETHREE=` cat fse_t2_errors.log | grep sisco2unc | tail -n 1 | sed "s/\'//g" | awk '{printf "%.0d\n", $NF}' `
process_fse_t2 ${IMFOUR} 2> fse_t2_errors.log
SCALEFOUR=` cat fse_t2_errors.log | grep sisco2unc | tail -n 1 | sed "s/\'//g" | awk '{printf "%.0d\n", $NF}' `

# these scale factors are rounded down
echo "scale factors used..."
echo ${SCALEONE}
echo ${SCALETWO}
echo ${SCALETHREE}
echo ${SCALEFOUR}


#find the minimum value - bit clunky!
MINM=NULL

test ${SCALEONE} -ne ${SCALETWO} && MINM=${SCALEONE}
test ${SCALETWO} -lt ${SCALEONE} && MINM=${SCALETWO}
( test ${SCALETHREE} -lt ${SCALEONE} || test ${SCALETHREE} -lt ${SCALETWO} ) && MINM=${SCALETHREE}
( test ${SCALEFOUR} -lt ${SCALEONE} || test ${SCALEFOUR} -lt ${SCALETWO} || test ${SCALEFOUR} -lt ${SCALETHREE} ) && MINM=${SCALEFOUR}

if test ${MINM} != "NULL" 
then
	echo "rescaling"
	test ${SCALEONE} -ne ${MINM} && avwmaths ${IMONE%.fid} -div ${SCALEONE} -mul ${MINM} ${IMONE%.fid}
	test ${SCALETWO} -ne ${MINM} && avwmaths ${IMTWO%.fid} -div ${SCALETWO} -mul ${MINM} ${IMTWO%.fid}
	test ${SCALETHREE} -ne ${MINM} && avwmaths ${IMTHREE%.fid} -div ${SCALETHREE} -mul ${MINM} ${IMTHREE%.fid}
	test ${SCALEFOUR} -ne ${MINM} && avwmaths ${IMFOUR%.fid} -div ${SCALEFOUR} -mul ${MINM} ${IMFOUR%.fid}
fi

# interleave the images
avwinterleave ${IMONE%.fid} ${IMTHREE%.fid} temp_ac
avwinterleave ${IMTWO%.fid} ${IMFOUR%.fid} temp_bd
avwinterleave temp_ac temp_bd ${IMOUT}

rm -f temp_ac.* 
rm -f temp_bd.* 
rm -f ${IMONE%.fid}.hdr 
rm -f ${IMONE%.fid}.img 
rm -f ${IMTWO%.fid}.hdr 
rm -f ${IMTWO%.fid}.img 
rm -f ${IMTHREE%.fid}.hdr 
rm -f ${IMTHREE%.fid}.img 
rm -f ${IMFOUR%.fid}.hdr 
rm -f ${IMFOUR%.fid}.img

# correct voxel sizes
# running on godot, so old version of avw utils
# need to stay as ANALYZE format for bet to work
echo "scaling pixel dimensions by factor of 10"

XDIM=` avwhd -x ${IMOUT} | grep dx | cut -d "'" -f 2 `
YDIM=` avwhd -x ${IMOUT} | grep dy | cut -d "'" -f 2 `

NEWXDIM=` echo "10 * ${XDIM} "| bc -l `
NEWYDIM=` echo "10 * ${YDIM} "| bc -l`
NEWZDIM=5

avwchpixdim ${IMOUT} ${NEWXDIM} ${NEWYDIM} ${NEWZDIM}

# use rbet
# probably better to get coords for brain centre properly, but these values seem to work OK
# need to manually correct the mask anyway

echo "Using Dave Lythgoe rbet variant of bet"
#rbet ${IMOUT} ${IMOUT}_rbet -v -f 0.5 -m -n -c 200 250 150 -r 60 -x 1.4 -y 1.25 -z 3
#the values below work for the 3.2x3.2 FOV images, above for the 4.2x3.2
rbet ${IMOUT} ${IMOUT}_rbet -v -f 0.3 -m -n -c 150 250 150 -r 60 -x 1.4 -y 1.25 -z 3

avwchfiletype NIFTI_GZ ${IMOUT}
avwchfiletype NIFTI_GZ ${IMOUT}_rbet_mask


