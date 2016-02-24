#!/usr/local/bin/bash
# this takes amares txt output on the standard input
# outputs the amplitudes on standard output
# version 1
# mjt 2007-02

cat /dev/stdin |sed -n -r '/^Ampl/,/^Stan/p' |grep -r -v ^[A-Za-z].*  | sed 's/\t$//g'


