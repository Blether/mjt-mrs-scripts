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
# ${studyid}_study tweaks 2007-04
# made flexible to cope with various studies 2007-04
# 2008-09 make work with ketamine study subdirs
#
# $1 study
# $2 scan number
#
studyid=$1
scanid=$2
SUBDIR=$3
datadir="${HOME}/scratch/${studyid}_analysis/original_scans"
outdir="${HOME}/scratch/${studyid}_analysis/lcm_analysis"
if [ ${studyid} != "atrisk" ] ;
then
series='press26_64'
else
series='press26'
fi
wseries='press26w'
te='26'
# scans in (datadir)/{scan number}/{series}.fid
# varian2raw at ~/.lcmodel/varian/varian2raw
# creates controlfile in scan directory
# uses basis file in ~/basisfiles/
# creates results in (outdir)/te{te}/
#
# --------------
# run varian/bin2raw to create RAW file
if ! test -f $datadir/${scanid}/${series}.fid/RAW
	then
	${HOME}/.lcmodel/varian/varian2raw $datadir/${scanid}/${SUBDIR}/${series}.fid/fid $datadir/${scanid}/${SUBDIR}/${series}.fid
	echo "varian bin2raw done"
fi

# RAW file for non-water suppressed if appropriate
ecc="0"
if test -f $datadir/${scanid}/${SUBDIR}/${wseries}.fid/fid
	then
	ecc="1"
	h2file="$datadir/${scanid}/${SUBDIR}/${wseries}.fid/RAW"
	if ! test -f $h2file
		then
		${HOME}/.lcmodel/varian/varian2raw $datadir/${scanid}/${SUBDIR}/${wseries}.fid/fid $datadir/${scanid}/${SUBDIR}/${wseries}.fid
	fi
fi

# --------------
# generate the lcm .CONTROL file
controlfile="$outdir/te${te}/${scanid}_${SUBDIR}_${series}.control"
echo " \$LCMODL" > $controlfile
echo " OWNER='FMRIB Centre, University of Oxford'" >> $controlfile
echo " KEY=217638264" >> $controlfile
echo " TITLE= '${scanid} ${SUBDIR} ${series}'" >> $controlfile
echo " FILBAS='${HOME}/basisfiles/press_te${te}_3t_01b.basis'" >> $controlfile
echo " FILPS='$outdir/te${te}/${scanid}_${SUBDIR}_${series}.ps'" >> $controlfile
echo " FILTAB='$outdir/te${te}/${scanid}_${SUBDIR}_${series}.table'" >> $controlfile
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
#echo " dows= F" >> $controlfile
echo " dows= T" >> $controlfile
echo " HZPPPM=127.335" >> $controlfile
echo " IETCOU=3" >> $controlfile
echo " ipage2= 2" >> $controlfile
echo " NUNFIL=1024" >> $controlfile
echo " pgnorm='A4'" >> $controlfile
echo " ppmend= 0.2" >> $controlfile
echo " ppmst= 4.0" >> $controlfile
#echo " ppmst= 3.6" >> $controlfile
echo " sddegp= 6" >> $controlfile
echo " SHIFMN=2*-2.5" >> $controlfile
echo " SHIFMX=2*-2.0" >> $controlfile
echo " SDDEGP=6" >> $controlfile
echo " FILRAW= '$datadir/${scanid}/${SUBDIR}/${series}.fid/RAW'" >> $controlfile
echo " \$END" >> $controlfile
chmod 'u+x' $controlfile
echo "running LCmodel"

# -----------
# run LCmodel
lcmodel < $controlfile
echo "LCmodel complete"

# display results
