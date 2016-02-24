#!/usr/local/bin/bash
# script to take fid files and produce data
# suitable for import into matlab
#
# Matt Taylor 2007-06-26
v2r='/home/fs0/taylor/.lcmodel/varian/varian2raw'
outname=${1##*/}

${v2r} ${1}/fid ./

cat RAW | grep -e '^\ \ ' >RAWnh
mv RAWnh ${outname}.RAWnh
