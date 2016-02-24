#!/usr/local/bin/bash
# adds suitable header to RAWnh file
# so is a RAW file
#
# Matt Taylor 2007-06-26

infile=${1}
outfile=${2}

echo ' $SEQPAR' >${outfile}
echo ' hzpppm=127.3363' >>${outfile}
echo ' echot=68.0' >>${outfile}
echo ' $END' >>${outfile}
echo ' $NMID' >>${outfile}
echo " fmtdat='(2e14.5)'" >>${outfile}
echo ' tramp=1.' >>${outfile}
echo ' volume=1.' >>${outfile}
echo ' $END' >>${outfile}
cat ${infile} >>${outfile}
