#!/bin/bash
# takes dlm output by matlab
# and converts number formatting etc to be the same
# as in a RAW file
# producing a RAWnh file
#
# Matt Taylor 2007-06-26

infile=${1}
outfile=${1}.rawnh

cat ${infile} | sed 's/\ -/-/g' | tr 'E' 'e'  > ${outfile}
