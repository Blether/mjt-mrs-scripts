# runlcm: 	run lcm
#    		create .CONTROL file for lcm, run and display output ps
# 		do ECC 
# altered by mjt on 16th nov 2005  and again 31 nov
# currently the documentation is not entirely correct
# check the actual script for what it does
# 
# altered to do eddy current correction if poss
# mjt 2006-05-08
# tryptophan study tweaks 30-03-2007
# cital2_study tweaks 2007-04
#
# $1 scan number
#
datadir="/home/fs0/taylor/scratch/cital2_analysis/original_scans"
outdir="/home/fs0/taylor/scratch/cital2_analysis/lcm_analysis"
series='press26_64'
wseries='press26w'
te='26'
# scans in (datadir)/{scan number}/{series}.fid
# varian2raw at ~/lcmodel/varian/varian2raw
# creates controlfile in scan directory
# uses basis file in ~/basisfiles/
# creates results in (outdir)/te{te}/
#
#
# requires:
#   RAW file in ~/lcm/{scan_number}/press{o/f}{TE} 
#         e.g. ~/lcm/{scan_number}/presso68/RAW
#   ~/lcm/saved/rd_gaba/press/ directory (for output .ps and .table) 
#
#
# --------------
# run varian/bin2raw to create RAW file
if ! test -f $datadir/$1/${series}.fid/RAW
	then
	/home/fs0/taylor/lcmodel/varian/varian2raw $datadir/$1/${series}.fid/fid $datadir/$1/${series}.fid
	echo "varian bin2raw done"
fi

# RAW file for non-water suppressed if appropriate
ecc="0"
if test -f $datadir/$1/${wseries}.fid/fid
	then
	ecc="1"
	h2file="$datadir/$1/${wseries}.fid/RAW"
	if ! test -f $h2file
		then
		/home/fs0/taylor/lcmodel/varian/varian2raw $datadir/$1/${wseries}.fid/fid $datadir/$1/${wseries}.fid
	fi
fi

# --------------
# generate the lcm .CONTROL file
controlfile="$outdir/te${te}/$1_${series}.control"
echo " \$LCMODL" > $controlfile
echo " OWNER='FMRIB Centre, University of Oxford'" >> $controlfile
echo " KEY=217638264" >> $controlfile
echo " TITLE= '$1 press ${series}'" >> $controlfile
echo " FILBAS='/home/fs0/taylor/basisfiles/press_te${te}_3t_01b.basis'" >> $controlfile
echo " FILPS='$outdir/te${te}/$1_${series}.ps'" >> $controlfile
echo " FILTAB='$outdir/te${te}/$1_${series}.table'" >> $controlfile
echo " ltable= 7" >> $controlfile
echo " DELTAT=.000500" >> $controlfile
if [ $ecc == 1 ]
	then
		echo " DOECC= T" >> $controlfile
		echo " FILH2O='$h2file'" >> $controlfile
	else
		echo " doecc= F" >> $controlfile
fi
echo " dorefs= T" >> $controlfile
echo " dows= F" >> $controlfile
echo " HZPPPM=127.335" >> $controlfile
echo " IETCOU=3" >> $controlfile
echo " ipage2= 2" >> $controlfile
echo " NUNFIL=1024" >> $controlfile
echo " pgnorm='A4'" >> $controlfile
echo " ppmend= 0.2" >> $controlfile
echo " ppmst= 4.0" >> $controlfile
echo " sddegp= 6" >> $controlfile
echo " SHIFMN=2*-2.5" >> $controlfile
echo " SHIFMX=2*-2.0" >> $controlfile
echo " SDDEGP=6" >> $controlfile
echo " FILRAW= '$datadir/$1/${series}.fid/RAW'" >> $controlfile
echo " \$END" >> $controlfile
chmod 'u+x' $controlfile
echo "running LCmodel"

# -----------
# run LCmodel
lcmodel < $controlfile
echo "LCmodel complete"

# display results
