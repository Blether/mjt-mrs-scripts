#!/usr/bin/python
# Matthew Taylor 2011-12-10
# extracts MRS voxel position information from header of GE P.7 file
# needs rdgehdr somewhere in the path. That can be downloaded here: http://rsl.stanford.edu/research/software.html
#
# usage: voxpos_ge.py (Pfile)
# outputs: (Pfile).voxel - voxel position [also on standard output], (Pfile).voxpos.p - python pickle object with same information

# initially run on python 2.6; tried to make compatible with older versions too...

import sys
import os.path
import subprocess
import pickle

pfilename = sys.argv[1]
pfileheader = pfilename + '.header'
pfilevoxpos = pfilename.split('.')[0] + '.voxpos.p'
pfilevoxel = pfilename.split('.')[0] + '.voxel'
gehdrprog='Pfile_info'

# check is necessary header info exists, or extract it as required
# rdgehdr is available online, Pfile_info installed on IOP systems
if not os.path.isfile(pfileheader):
	print('no header file yet: making one')
	commandtouse =(gehdrprog + ' ' +pfilename + ' | strings > ' + pfileheader ) 
	p = subprocess.call(commandtouse, shell=True)

# using existing text file
#with open(pfileheader,'r') as f:
try:
	f = open(pfileheader,'r')
	hdrinfo = f.read()
	f.close()
except:
	print ('error opening header file...')
	raise

# parse the header
# IOP process uses user defined value fields
# should check if they ever differ from those used below

voxpos = {'xc': '1', 'xd': '1', 'yc': '1', 'yd': '1', 'zc': '1', 'zd': '1'}

# from Pfile header info, the 'x' appears to really be Y and vice versa...
# currently uses the 'humanised' descriptors from rdgehdr, should make 
# tolerate the output of Pfile_info too

for line in hdrinfo.splitlines():
	#words = line.partition(':') # needs python 2.5 or higher
	words = line.split(':')
	if 'RX x CSI volume dimension' in words[0]:
		voxpos['yd'] = str.lstrip(words[1])
	elif 'RX x CSI volume center' in words[0]:
		voxpos['yc'] = str.lstrip(words[1])
	elif 'RX y CSI volume dimension' in words[0]:
		voxpos['xd'] = str.lstrip(words[1])
	elif 'RX y CSI volume center' in words[0]:
		voxpos['xc'] = str.lstrip(words[1])
	elif 'RX z CSI volume dimension' in words[0]:
		voxpos['zd'] = str.lstrip(words[1])
	elif 'RX z CSI volume center' in words[0]:
		voxpos['zc'] = str.lstrip(words[1])
	# to cope with header files from Pfile_info
	# RX X CSI ....   becomes 'roilenx' with = as separator
	words = line.split('=')
	if 'roilenx' in words[0]:
		voxpos['yd'] = str.lstrip(words[1])
	elif 'roilocx' in words[0]:
		voxpos['yc'] = str.lstrip(words[1])
	elif 'roileny' in words[0]:
		voxpos['xd'] = str.lstrip(words[1])
	elif 'roilocy' in words[0]:
		voxpos['xc'] = str.lstrip(words[1])
	elif 'roilenz' in words[0]:
		voxpos['zd'] = str.lstrip(words[1])
	elif 'roilocz' in words[0]:
		voxpos['zc'] = str.lstrip(words[1])

# correct the sign! check this is the correct axis to flip (LR?)
# may not be needed - sign is opposite in the 'User variable' definition, so getting it from the 'RX...' entry may solve this already
voxpos['yc'] = str(-1 * float(voxpos['yc']))

#with open(pfilevoxpos, 'w') as outfile:
try:
	outfile = open(pfilevoxpos, 'w')
	pickle.dump(voxpos, outfile)
	outfile.close()
except:
	print ('problem writing voxpos pickle file')

#with open(pfilevoxel, 'w') as outfile:
#strvoxpos = str([voxpos['xc'], voxpos['xd'], voxpos['yc'], voxpos['yd'], voxpos['zc'], voxpos['zd']]).translate(None, '\',\[\]') +'\n'
strvoxpos = " ".join([voxpos['xc'], voxpos['xd'], voxpos['yc'], voxpos['yd'], voxpos['zc'], voxpos['zd']])
try:
	outfile = open(pfilevoxel, 'w')
	outfile.write(strvoxpos)
	outfile.close()
	print (strvoxpos)
except:
	print ('problem writing voxel file')
	print (strvoxpos)
