#!/usr/local/bin/bash
# this takes a file of amares txt output
# outputs the amplitudes as a dlm that matlab is happy to import
# version 1
# mjt 2007-02
INFILE=$1
OUTFILE='amplitudes.dlm'

cat $INFILE |sed -n -r '/^Ampl/,/^Stan/p' |grep -r -v ^[A-Za-z].*  | sed 's/\t$//g' > $OUTFILE


