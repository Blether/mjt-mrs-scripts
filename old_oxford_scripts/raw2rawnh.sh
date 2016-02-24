#!/bin/bash
# cuts header from RAW file in pwd
if test -f "RAW"
then
	cat RAW | grep -e '^\ \ ' >RAWnh
fi
