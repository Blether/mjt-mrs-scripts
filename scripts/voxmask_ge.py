#!/usr/bin/python
# Matthew Taylor 2012-12-10
# becoming functional on the test data at least
# at various points the 'X' (LR or RL) data is treated opposite to the other axes; differences in conventions
# the mask size will probably not be perfect while the ROI was not an integer multiple of structural image voxels
# does not correct for rotations of voxel space relative to structural scan
# usage: voxmask_ge.py (Pfile) (structural image)
# outputs: Pfile_voxel_mask.nii.gz

# initially written for python 2.6, adjusted so should also work in older versions

import sys
import pickle
import subprocess

# use voxposition to make voxel mask image
pfilename = sys.argv[1]
voxfile = pfilename.split('.')[0] + '.voxpos.p' 
strucimg = sys.argv[2]
maskimg = pfilename.split('.')[0] + '_voxel_mask.nii.gz'
matfile = pfilename.split('.')[0] + '_mask_position.mat'
maskimg1a = pfilename.split('.')[0] + '_mask_start.nii.gz'

# voxel position as previously defined
#with open(voxfile, 'r') as f: # this method needs python 2.6?
try:
	f = open(voxfile, 'r')
	voxpos = pickle.load(f)
	f.close()
except:
	print ('problem opening voxfile')

# VOI size 
voisize= [ float(voxpos['xd']), float(voxpos['yd']), float(voxpos['zd']) ]
voicent= [ float(voxpos['xc']), float(voxpos['yc']), float(voxpos['zc']) ]
voisize_v= voisize
# currently this makes a mask at a scale of 1 voxel per mm and then it is corrected later in the application of the affine matrix
# alternatively could correct the scale at this point and then simply translate it into position
# voisize_v= [ float(voxpos['xd'])/float(strucdims['xpdim']), float(voxpos['yd'])/float(strucdims['ypdim']), float(voxpos['zd'])/float(strucdims['zpdim']) ]

sform_matrix = subprocess.Popen(['fslorient', '-getsform', strucimg], stdout=subprocess.PIPE).communicate()[0]
sform_matrix = sform_matrix.split()

# make voxel mask in corner of image 
subprocess.Popen(['fslmaths', strucimg, '-mul', '0', '-add', '1', '-roi', '0', str(voisize_v[0]), '0', str(voisize_v[1]), '0', str(voisize_v[2]), '0', '1', maskimg1a], stdout=subprocess.PIPE).communicate()[0]

# make appropriate matrices for transformation - this isn't right yet; stretches things
trans = [1,1,1]
trans[0] = (float(sform_matrix[3]) * 1 ) + (voicent[0] *-1) + (voisize[0]/2 * 1)
trans[1] = (float(sform_matrix[7]) * -1) + (voicent[1]) + (voisize[1]/2 * -1)
trans[2] = (float(sform_matrix[11]) * -1) + (voicent[2]) + (voisize[2]/2 * -1)

# scale factor to apply
# get from sform_matrix for each image
scales_axes = [-1,1,1]
scales_axes[0] = (1 / float(sform_matrix[0]))
scales_axes[1] = (1 / float(sform_matrix[5]))
scales_axes[2] = (1 / float(sform_matrix[10]))

# write out the matrix file to use 
# with open(matfile, 'w') as f:
try:
	f = open(matfile, 'w')
	f.write(str(scales_axes[0]) + ' 0 0' + ' ' + str(trans[0]) + '\n')
	f.write('0 ' + str(scales_axes[1]) +' 0' + ' ' + str(trans[1]) + '\n')
	f.write('0 0 '+ str(scales_axes[2]) + ' ' + str(trans[2]) + '\n')
	#f.write(" ".join(sform_matrix[1:3]) + ' ' + str(trans[0]) + '\n') # not the approach to take
	f.write( '0 0 0 1\n')
	f.close()
except:
	print ('problem writing matrix for translation')

# move voxel mask to correct position
subprocess.Popen(['flirt', '-in', maskimg1a, '-ref', strucimg, '-out', maskimg, '-applyxfm', '-init', matfile, '-interp', 'nearestneighbour'],  stdout=subprocess.PIPE).communicate()[0]

