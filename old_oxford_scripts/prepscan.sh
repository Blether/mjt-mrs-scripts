#!/usr/local/bin/bash
#
# this little script prepares a varian scan for use by matlab
# mjt 2006-05-20
if test -f "RAW"
	then echo "RAW present"
	else
	~/.lcmodel/varian/varian2raw ./fid ./
fi
if test -f "RAWnoheader"
	then echo "RAWnoheader present"
	else
	cat RAW | grep -e '^\ \ ' >RAWnoheader
fi
# leave expt name
if ! test -f "title"
	then
	 pwd |awk ' BEGIN {FS="/"};{print $(NF-1) " " $NF}' |sed 's/\.fid$//' |sed 's/\_/ /g' |sed 's/^/\"/' |sed 's/$/\"/' >title
fi
