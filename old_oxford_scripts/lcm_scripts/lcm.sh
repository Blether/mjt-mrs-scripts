# runlcm: 	run lcm
#    		create .CONTROL file for lcm, run and display output ps
# 		do ECC 
# altered by mjt on 16th nov 2005  and again 31 nov
# currently the documentation is not entirely correct
# check the actual script for what it does
# 
# altered to do eddy current correction if poss
# mjt 2006-05-08
#
# $1 scan number
# $2 series
# $3 TE
#
datadir="/home/fs0/taylor/scratch/lcmtest"
outdir="/home/fs0/taylor/scratch/lcmresults/lcmtest"
# scans in (datadir)/{scan number}/{series}/fid
# varian2raw at ~/lcmodel/varian/varian2raw
# creates controlfile in scan directory
# uses basis file in ~/basisfiles/
# creates results in (outdir)/tenn/
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
if ! test -f $datadir/$1/$2.fid/RAW
	then
	/home/fs0/taylor/lcmodel/varian/varian2raw $datadir/$1/$2.fid/fid $datadir/$1/$2.fid
	echo "varian bin2raw done"
fi

# RAW file for non-water suppressed if appropriate
ecc="0"
if test -f $datadir/$1/$2w.fid/fid
	then
	ecc="1"
	h2file="$datadir/$1/$2w.fid/RAW"
	if ! test -f $h2file
		then
		/home/fs0/taylor/lcmodel/varian/varian2raw $datadir/$1/$2w.fid/fid $datadir/$1/$2w.fid
	fi
fi

# --------------
# generate the lcm .CONTROL file
controlfile="$outdir/te$3/$1_$2.control"
echo " \$LCMODL" > $controlfile
echo " OWNER='FMRIB Centre, University of Oxford'" >> $controlfile
echo " KEY=217638264" >> $controlfile
echo " TITLE= '$1 press $2'" >> $controlfile
echo " FILBAS='/home/fs0/taylor/basisfiles/press_te$3_3t_01b.basis'" >> $controlfile
echo " FILPS='$outdir/te$3/$1_$2press.ps'" >> $controlfile
echo " FILTAB='$outdir/te$3/$1_$2press.table'" >> $controlfile
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
echo " FILRAW= '$datadir/$1/$2.fid/RAW'" >> $controlfile
echo " \$END" >> $controlfile
chmod 'u+x' $controlfile
echo "running LCmodel"

# -----------
# run LCmodel
lcmodel < $controlfile
echo "LCmodel complete"

# display results
gv -seascape $outdir/te$3/$1_$2press.ps &
