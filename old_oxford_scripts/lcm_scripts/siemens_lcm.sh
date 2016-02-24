#!/bin/sh
# file from provencher. changes by jamie near, also matt Taylor (2010)
# handles drift corrected data from Jamie's matlab process now - both SPECIAL and lactate PRESS (Dec 2010)
# 
# sample usage:
# siemens_lcm.sh ifn1 N10_01_005 lactate_3 nodc
#

# April 2011; fixed bug - calculation of nunfil needs improving; fails if more than expected number of lines in header

STUDY=$1
SUB_FOLDER=$2
SUBSUB_FOLDER=$3
DC_OPTION=$4

if [ ${DC_OPTION} == 'dc' ]; then
	#use drift corrected data, already provided in raw format
	echo using drift corrected data
	RAW_READY=1
	DATA_FILE_FILTER=*_DriftCorr
else
	DC_OPTION='nodc'
	DATA_FILE_FILTER=*.rda
	RAW_READY=0
fi

SEQUENCE=`echo ${SUBSUB_FOLDER} | cut -d '_' -f1`
ECC=0
DATA_DIR=${HOME}/scratch/${STUDY}/original_scans/$SUB_FOLDER/$SUBSUB_FOLDER/
WATER_DIR=${HOME}/scratch/${STUDY}/original_scans/$SUB_FOLDER/${SUBSUB_FOLDER}_w/

if [ ${DC_OPTION} == 'dc' ]; then
	OUTPUT_DIR=${HOME}/scratch/${STUDY}/lcmodel/${SUB_FOLDER}
	TEMP_DIR=${HOME}/scratch/${STUDY}/lcmodel/$SUB_FOLDER/work_${SUBSUB_FOLDER}_dc
	#NUNFIL_CALC=$( echo `wc -l ${DATA_DIR}/$DATA_FILE_FILTER | cut -d ' ' -f1` -10 |bc )
	NUNFIL_CALC=$( cat ${DATA_DIR}/$DATA_FILE_FILTER | sed -n '/^\ \ /,$p' |wc -l )
	echo calculated NUNFIL ${NUNFIL_CALC}
	# define appropriate DELTAT values to be used
	if [ ${SEQUENCE} == 'special' ]; then
		DELTAT=.00025
	else
		DELTAT=0.0004167
	fi
	echo applied DELTAT ${DELTAT}
else
	OUTPUT_DIR=${HOME}/scratch/${STUDY}/lcmodel/$SUB_FOLDER
	TEMP_DIR=${HOME}/scratch/${STUDY}/lcmodel/$SUB_FOLDER/work_$SUBSUB_FOLDER
fi
DATA_TYPE=siemens

if [ ${SEQUENCE} == 'press' ]; then
	echo Analyse as PRESS
	FILBAS=${HOME}/basisfiles/gamma_press_te30_123mhz_104.basis
elif [ ${SEQUENCE} == 'special' ]; then
	echo Analyse as SPECIAL
	FILBAS=${HOME}/basisfiles/jn_special_3T_te8p5_1Hzlw_sw2000_bHB_kaiser.basis
	# this newer basis set uses improved coupling constants for GABA -> cleaner triplets at 3 ppm
	# FILBAS=${HOME}/basisfiles/jn_special_te8p5_123mhz_alt.basis
else
	echo Analyse as long TE PRESS for lactate
	# the _b version uses PCh not PCho so LCModel does overall PCh+GPC
	FILBAS=${HOME}/basisfiles/jn_press_te270_123mhz_b.basis
fi

mkdir  -p  $TEMP_DIR/met
mkdir  -p  $TEMP_DIR/h2o
mkdir  -p  $OUTPUT_DIR
rm  -f  $TEMP_DIR/runtime-messages

if test -f ${TEMP_DIR}/met/RAW; then
	echo already processed met RAW file
else
	if test -d $DATA_DIR; then
		cd  $DATA_DIR   # <------------ cd
		for  PATHNAME  in  $DATA_FILE_FILTER
		do
			if [ ${RAW_READY} != 1 ]; then
				if ! test -f ${TEMP_DIR}/met/RAW; then 
					${HOME}/.lcmodel/$DATA_TYPE/bin2raw  $PATHNAME  $TEMP_DIR/  met
				else
					echo already have RAW file processed. proceeding
				fi
			else
				# copy file into the RAW position
				cp ${DATA_DIR}/${PATHNAME} ${TEMP_DIR}/met/RAW
			fi
		done
	else
		echo could not find DATA_DIR
	fi

fi
	if test -f ${TEMP_DIR}/h2o/RAW; then 
		echo already processed water RAW file
		ECC=1
		echo Applying eddy current correction and water scaling
	else
		if test -d $WATER_DIR; then
			cd $WATER_DIR
			if test -f $DATA_FILE_FILTER; then
				ECC=1
				echo Applying eddy current correction and water scaling
				if [ ${RAW_READY} != 1 ]; then
					${HOME}/.lcmodel/$DATA_TYPE/bin2raw  $DATA_FILE_FILTER  $TEMP_DIR/ h2o 
				else
					# copy file into the correct subdir as RAW
					cp ${WATER_DIR}/${DATA_FILE_FILTER} ${TEMP_DIR}/h2o/RAW
				fi
			fi
			cd -
		fi
	cd -
	fi

if test ! -f ${TEMP_DIR}/met/RAW; then
	echo could not find RAW file - exiting 
	exit 0
fi

rm  -f  $TEMP_DIR/control
echo "  \$LCMODL" > $TEMP_DIR/control
if test -f ${TEMP_DIR}/met/cpStart; then
	echo " title= '`cat ${TEMP_DIR}/met/cpStart | grep ^title | cut -d' ' -f4-9 `' " >>$TEMP_DIR/control
	sed  -e '/^filps/d' \
		     -e '/^title/d' \
		     -e 's/^/ /'  $TEMP_DIR/met/cpStart  >> $TEMP_DIR/control
	echo " filps='$OUTPUT_DIR/${SUBSUB_FOLDER}.ps' 
	 filtab='$OUTPUT_DIR/${SUBSUB_FOLDER}.table'">> ${TEMP_DIR}/control
else
	echo " title= 'drift corrected ${SUB_FOLDER} ${SUBSUB_FOLDER}'
 filraw='${TEMP_DIR}/met/RAW'
 filps='$OUTPUT_DIR/${SUBSUB_FOLDER}_dc.ps'
 filtab='$OUTPUT_DIR/${SUBSUB_FOLDER}_dc.table'
 hzpppm=123.24
 deltat=$DELTAT
 dorefs(1)=F" >> $TEMP_DIR/control
	echo " nunfil=${NUNFIL_CALC}" >> $TEMP_DIR/control
fi
	     NO_EXTENSION=`echo "$PATHNAME" | cut -d. -f1`

     echo " lps=8
 owner='FMRIB Centre, University of Oxford'
 key=217638264
 ltable=7
 filbas='$FILBAS'" >> $TEMP_DIR/control

# change ppm range to be same as Mekle analysis for SPECIAL data 2dec 2010
if [ ${SEQUENCE} == 'special' ]; then
echo " PPMST=4.2
 PPMEND=0.2" >> $TEMP_DIR/control
fi

	     if [ ${ECC} == 1 ]; then
	     echo " DOECC= T
 DOWS = T
 FILH2O='${TEMP_DIR}/h2o/RAW'" >> $TEMP_DIR/control
	     fi
	     echo " \$END" >> $TEMP_DIR/control

${HOME}/.lcmodel/bin/lcmodel  <$TEMP_DIR/control  \
	2>>$TEMP_DIR/runtime-messages

		     if test -f ${TEMP_DIR}/met/error ; then
		     cat ${TEMP_DIR}/*/error >&2
fi


		     echo "*** lcmodel script completed. ***"
		     exit 0
