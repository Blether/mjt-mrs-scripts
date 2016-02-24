#!/bin/bash
# script to take an jMRUI txt file and
# remove textual elements to yield a simple
# 4 by n matrix suitable for import into
# matlab
#
# mjt 2006-08-22

cat $1 | sed '1,20d' | sed -n '/igna/!p' > $2
#cat $1 | sed '1,20d' | sed -n '/igna/!p' > numbers.txt

