#!/opt/csw/bin/python
import commands
import sys
try:	file=sys.argv[3]
except: file="CNS*005"
info=commands.getoutput("Pfile_info "+sys.argv[1])
descrst=info.find("series_description")
desc=info[descrst:info.find('\n',descrst)]
rsstart=info.find("user_defined_variable_8")
rs=(info[rsstart+25:info.find('\n',rsstart)])
asstart=info.find("user_defined_variable_9")
as=(info[asstart+25:info.find('\n',asstart)])
sstart=info.find("user_defined_variable_10")
ss=(info[sstart+26:info.find('\n',sstart)])
rpstart=info.find("user_defined_variable_11")
rp=(info[rpstart+26:info.find('\n',rpstart)])
lp=str(-float(rp))
apstart=info.find("user_defined_variable_12")
ap=(info[apstart+26:info.find('\n',apstart)])
spstart=info.find("user_defined_variable_13")
sp=(info[spstart+26:info.find('\n',spstart)])
print ("s="+sp+" "+ss+"\n"+"r="+rp+" "+rs+"\n"+"a="+ap+" "+as+"\n")
print desc+'\n'
segment=commands.getoutput("gwsegmentax "+file+" "+sys.argv[2]+" spgr_seg1 spgr_seg2 spgr_seg3 "+sp+" "+ss+" "+lp+" "+rs+" "+ap+" "+as)
print(segment)
