#!/usr/bin/Rscript
# reads in the affine matrix .mat file specfied as the argument and outputs a crude estimate of rotation around the three orthogonal axes
# Matt Taylor 2010-01-25
args = commandArgs(TRUE)
affine = read.table(args[1])
c(asin(affine[3,2]), asin(affine[1,3]), asin(affine[2,1]))*180/pi
q()
