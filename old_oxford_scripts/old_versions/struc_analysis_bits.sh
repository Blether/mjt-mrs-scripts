

extract_brain.sh ${4} ${1} ${2}
get_voxel.sh ${4} ${1} ${2} pre
cd ${3}/structural
makevoxelmask.sh ${1%%_*}.voxel
get_vox_contents.sh ${4} ${1}
voxel_2_mnispace.sh ${4} ${1%%_*}
cd ..
