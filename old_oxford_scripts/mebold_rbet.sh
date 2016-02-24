#!/usr/local/bin/bash
#
# runs the Dave Lythgoe rbet variant of bet
# on the mebold images 
# processed with Andrew Lowe's process_me_fmri
#
# Matthew Taylor 2008-01-30

INFILE=$1

rbet ${INFILE} ${INFILE}_rbet -v -f 0.5 -m -n -c 150 50 250 -r 60 -x 1.4 -y 1.25 -z 3
