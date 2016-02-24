# code to generate plot of PRESS 026 and PRESSJ
# spectra from individual
# for transfer report in the first instance
# mjt 30-04-2007
#
# take mrui files, save as mruitxt, then strip headers
# third column then contains the real component of the spectrum

prange<-(400:600)

p26<-read.table('example_p026_nh.txt')
teav<-read.table('example_teav_nh.txt')

#pdf('pressplot_p.pdf',width=4,height=4)
oldpar<-par(no.readonly=TRUE)
#par(mfcol=c(2,1))
par(pch=19)

#par(mfg=c(1,1))
plot(p26[prange,3],type='l',ylab='amplitude',xlab='frequency (ppm)',axes=FALSE,main='PRESS')
axis(side=1,at=c(-50,16,80,144,max(prange)),labels=c('','4.0','3.0','2.0',''))
text(120,max(p26[prange,3])*.5,'Glx')
text(163,max(p26[prange,3])/1.03,'NAA')
text(90,max(p26[prange,3])*.73,'Cr')
text(16,max(p26[prange,3])*.53,'Cr')
text(65, max(p26[prange,3])*.73, 'Cho')
text(44, max(p26[prange,3])*.63, 'mI')
#dev.off()

#pdf('pressplot_pj_s.pdf', width=4,height=4)
#par(mfg=c(2,1))
plot(teav[prange,3],type='l',ylab='',xlab='frequency (ppm)',axes=FALSE,main='PRESS-J')
axis(side=1,at=c(-50,16,80,144,max(prange)),labels=c('','4.0','3.0','2.0',''))
text(120,max(teav[prange,3])/4,'Glu')
text(163,max(teav[prange,3])/1.03,'NAA')
text(90,max(teav[prange,3])*.73,'Cr')
text(16,max(p26[prange,3])*.43,'Cr')
text(64, max(p26[prange,3])*.76, 'Cho')
text(46, max(p26[prange,3])*.3, 'mI')

#dev.off()
#pdf('pressplot_pj_p.pdf', width=4, height=4)
teavp=read.table('example_teav_p.dlm')
teavp_s_a=array(teavp[,3], dim=c(1024,16))
par(mfcol=c(4,4))
par(mar=c(3,2,2,1)+0.1)
for (k in 1:16) {
plot(1:length(prange),teavp_s_a[prange,k], type='l', axes=FALSE, ylab='', xlab='')
}
#dev.off()

par(oldpar)
