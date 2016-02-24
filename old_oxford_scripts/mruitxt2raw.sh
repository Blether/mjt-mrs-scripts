#!/bin/bash
#
# take mrui .txt data file and output a RAWnh file 
# that can be made acceptable to LCModel
#
# Matthew Taylor 2009-01-29
INFILE=$1
OUTFILE=${INFILE}.rawnh
RAW_HEADER=${2}
RAWFILE=RAW

cat ${INFILE} | sed '1,20d' | sed -n '/igna/!p'  | sed 's/\ -/-/g'  | sed 's/E/e\+0/g' \
	| gawk '{printf "   %2.4e   %2.4e\n", $1, $2}' \
 | sed 's/\ -/-/g'  > ${OUTFILE}

cat ${RAW_HEADER} > ${RAWFILE}
cat ${OUTFILE} >> ${RAWFILE}
