#!/bin/bash
# this script takes a matrix outputted by matlab
# and converts it into a suitably formatted file
# for use by jMRUI
#
# mjt 2006-08-22
# adjusted to be more convenient to call from matlab
# now asks for a filename to output
# and if necessary writes a plausible header itself
# mjt 2006-12-13

INFILE="$1"
OUTFILE="$2"

if [[ "$3" == "m" ]]
then
	multi=16
else
	multi=1
fi
# set defaults to either FMRIB scanner or physiol
fmrib=1

if test -f "$OUTFILE"
then
	cp $OUTFILE $(echo $OUTFILE | sed 's/\.txt$/_'$(date +%y%m%d%k%M)'\.txt/')
	head -n 20 $OUTFILE >newmrui.txt
else
	echo "jMRUI Data Textfile" >newmrui.txt
	echo "" >>newmrui.txt
	echo "Filename: "$OUTFILE >>newmrui.txt
	echo "" >>newmrui.txt
	if [[ "$fmrib" == "1" ]]
	then
		echo "PointsInDataset: 1024	" >>newmrui.txt
		echo "DatasetsInFile: "$multi >>newmrui.txt
		echo "SamplingInterval: 5E-1      " >>newmrui.txt
		echo "ZeroOrderPhase: 0E0       " >>newmrui.txt
		echo "BeginTime: 0E0       " >>newmrui.txt
		echo "TransmitterFrequency: 1.2734E8  " >>newmrui.txt
	else
		echo "PointsInDataset: 4096      " >>newmrui.txt
		echo "DatasetsInFile: "$multi >>newmrui.txt
		echo "SamplingInterval: 2E-1      " >>newmrui.txt
		echo "ZeroOrderPhase: 0E0       " >>newmrui.txt
		echo "BeginTime: 0E0       " >>newmrui.txt
		echo "TransmitterFrequency: 3.0022E8  " >>newmrui.txt
	fi
	#echo "DatasetsInFile: 16        " >>newmrui.txt
	#echo "DatasetsInFile: 1        " >>newmrui.txt
	echo "MagneticField: 4.7E0     " >>newmrui.txt
	echo "TypeOfNucleus: -1E0      " >>newmrui.txt
	echo "NameOfPatient: " >>newmrui.txt
	echo "DateOfExperiment: " >>newmrui.txt
	echo "Spectrometer: " >>newmrui.txt
	echo "AdditionalInfo: " >>newmrui.txt
	echo "" >>newmrui.txt
	echo "" >>newmrui.txt
	echo "Signal and FFT" >>newmrui.txt
	echo "sig(real)	sig(imag)	fft(real)	fft(imag)" >>newmrui.txt
fi
# correct number format
cat $INFILE | tr ' ' '\t' |sed 's/E-./F/g'|sed 's/E../E/g'|sed 's/F/E-/g' > ./mruitable2.txt
# deal appropriately with either long teav fid or single scan
#if [[ `cat $INFILE |wc -l ` < "10" ]]
if [[ $multi == "1" ]]
then
	echo Signal 1 out of 1 in file >>newmrui.txt
	cat mruitable2.txt >>newmrui.txt
else
	for n in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16
	do
	echo Signal $n out of 16 in file >>newmrui.txt
	if [[ "$fmrib" == "1" ]]
	then
		cat mruitable2.txt | sed -n ''$(($n*1024-1023))',+1023p' >>newmrui.txt
	else
		cat mruitable2.txt | sed -n ''$(($n*4096-4095))',+4095p' >>newmrui.txt
	fi
	done
fi

rm mruitable2.txt
mv newmrui.txt $OUTFILE
