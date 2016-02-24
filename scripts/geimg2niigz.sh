#!/bin/bash
# takes GE structural image and converts to NIFTI GZ format
# Matthew Taylor 2011-12-11

GEIMG=$1
OUTIMG=$2

# correct for presence or absence of suffixes etc

# unc2analyze - orientation image info is left lacking by this process
# dcm2nii as called by GrabRawDicom.scp may be more useful
unc2analyze ${GEIMG} ${OUTIMG}

fslchfiletype NIFTI_GZ ${OUTIMG} ${OUTIMG}.nii.gz

