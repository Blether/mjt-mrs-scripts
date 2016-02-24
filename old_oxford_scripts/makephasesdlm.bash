#!/usr/local/bin/bash
#
# this takes a file of amares txt output
# outputs the phases as a dlm that matlab is happy to import
# version 2
# mjt 2007-02
INFILE=$1
OUTFILE='phases.dlm'

cat $INFILE |sed -n -r '/^Phas/,/^Stan/p' |grep -r -v ^[A-Za-z].*  | sed 's/\t$//g' > $OUTFILE


