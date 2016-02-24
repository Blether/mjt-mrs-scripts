# runlcm: 	run lcm
#    		create .CONTROL file for lcm, run and display output ps
# 		do ECC 
#
# Generates .control in ~/lcm/control_files directory, which can then be used
# by LCM with "lcmodel < controlfile". All data should be stored in 
# ~lcm/mrs_data/{scan_no}, then the lcm results are saved in the ~/lcm/saved
# directory. 
#
# requires:
#   RAW file in ~/lcm/{scan_number}/press{o/f}{TE} 
#         e.g. ~/lcm/{scan_number}/presso68/RAW
#   ~/lcm/saved/rd_gaba/press/ directory (for output .ps and .table) 
#
# $1: scan no (including leading zeroes)
# $2: TE 
# $3: o(ccipital) / f(rontal)
#
# --------------
# run varian/bin2raw to create RAW file
varian2raw /usr/people/jevans/lcm/mrs_data/$1/press$3$2/fid /usr/people/jevans/lcm/mrs_data/$1/press$3$2
echo "varian bin2raw done"

# --------------
# generate the lcm .CONTROL file
controlfile="/usr/people/jevans/lcm/control_files/"$1$3".control"
echo " \$LCMODL" > $controlfile
echo " OWNER='FMRIB Centre, University of Oxford'" >> $controlfile
echo " KEY=217638264" >> $controlfile
echo " TITLE= '$1press$3$2'" >> $controlfile
echo " FILBAS='/usr/people/jevans/lcm/jebasis/press_te$2_3t_01b.basis'" >> $controlfile
echo " FILPS='/usr/people/jevans/lcm/saved/tryptophan/press/$1press$3$2.ps'" >> $controlfile
echo " FILTAB='/usr/people/jevans/lcm/saved/tryptophan/press/table/$1press$3$2.table'" >> $controlfile
echo " ltable= 7" >> $controlfile
echo " DELTAT=.000500" >> $controlfile
echo " doecc= F" >> $controlfile
echo " dorefs= T" >> $controlfile
echo " dows= F" >> $controlfile
echo " HZPPPM=127.335" >> $controlfile
echo " IETCOU=3" >> $controlfile
echo " ipage2= 2" >> $controlfile
echo " NUNFIL=1024" >> $controlfile
echo " pgnorm='A4'" >> $controlfile
echo " ppmend= 0.2" >> $controlfile
echo " ppmst= 4.3" >> $controlfile
echo " sddegp= 6" >> $controlfile
echo " SHIFMN=2*-2.5" >> $controlfile
echo " SHIFMX=2*-2.0" >> $controlfile
echo " SDDEGP=6" >> $controlfile
echo " FILRAW= '/usr/people/jevans/lcm/mrs_data/$1/press$3$2/RAW'" >> $controlfile
echo " \$END" >> $controlfile
chmod 'u+x' $controlfile
echo "running LCmodel"

# -----------
# run LCmodel
lcmodel < $controlfile
echo "LCmodel complete"

# display results
gv /usr/people/jevans/lcm/saved/tryptophan/press/$1press$3$2.ps &
