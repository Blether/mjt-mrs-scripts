#!/bin/bash
#
# take siemens rda file and produce a plot of the fft
# matt 2010-03-19
#
# uses lcmodel

STUDY=${1}
SCANNO=${2}
SUBTYPE=${3}
WORKDIR=${HOME}/scratch/${STUDY}

DATAFILE=${WORKDIR}/original_scans/${SCANNO}/${SUBTYPE}/*${SUBTYPE}.rda
OUTFILE=${WORKDIR}/lcmodel/${SCANNO}/${SUBTYPE}
TEMP_DIR=${WORKDIR}/lcmodel/${SCANNO}/work_${SUBTYPE}_plot
RAWFILE=${TEMP_DIR}/raw/RAW

PLOTRAW=${HOME}/.lcmodel/bin/plotraw
BIN2RAW=${HOME}/.lcmodel/siemens/bin2raw

#make raw file
mkdir -p $TEMP_DIR/raw
  ${BIN2RAW} ${DATAFILE}  $TEMP_DIR/ raw 

# get these from the cpstart file!
 #PS_TITLE="` cat ${TEMP_DIR}/raw/cpStart | egrep ^title |cut -d' ' -f3-8 `"
#echo ${PS_TITLE} # could put this into id field of RAW file if interested
echo " \$PLTRAW " >${TEMP_DIR}/infile
cat ${TEMP_DIR}/raw/cpStart | sed -n 4,6p >>${TEMP_DIR}/infile
 #HZPPPM=1.2324e+02
 #NUNFIL=1024
 #DELTAT=8.330e-04 
echo " FILRAW='${RAWFILE}'
 FILPS='${OUTFILE}.ps'
 DEGPPM=0.
 DEGZER=0.
 PLTIME=F
 PPMST=4.1
 PPMEND=1.0
 \$END " >>${TEMP_DIR}/infile
 ${PLOTRAW} <${TEMP_DIR}/infile
exit
