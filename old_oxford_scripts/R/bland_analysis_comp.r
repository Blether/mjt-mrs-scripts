#applying analysis as per bland/altman Lancet 1986 paper
data<-read.delim('vox_composition_lo_hi_res.txt',header=TRUE,sep=" ")
attach(data)

blandplot <- function (setone, settwo, xlimits, ylimits, mainlab, xlabel, ylabel, xmarks, ymarks) {
bias=mean(setone-settwo)
bias_sd=sd(setone-settwo)
ulim=bias+1.96*bias_sd
llim=bias-1.96*bias_sd
plot(0.5*(setone+settwo), (setone-settwo), main=mainlab ,xlab= xlabel, ylab= ylabel, xlim=xlimits, ylim=ylimits, axes=FALSE)
axis(1, at=xmarks)
axis(2, at=ymarks)
arrows(xlimits[1], c(ulim,bias,llim), xlimits[2], c(ulim,bias,llim), length=0, lty="dotted")
#text(max(0.5*(setone+settwo)),c(ulim,bias,llim)+0.002, labels=c('Limit of agreement','Bias (with 95% CIs)','Limit of agreement'))
bias_n=length((setone+settwo))
bias_se=sqrt(((bias_sd)^2)/bias_n)
# need to find way to properly calculate the t-stat for appropriate degrees of freedom
# fudge with 2 for the moment...
bias_t=2
bias_ci=c(bias+(bias_t*bias_se), bias-(bias_t*bias_se))
arrows( xlimits[1], bias_ci, xlimits[2], bias_ci, length=0, lty="dashed", col='red')
}

#compare lo1 and hires results
pdf('lo1_vs_hi.pdf',width=6, height=6, title="lo1 vs hires")
par(mfcol=c(2,2))
blandplot(lo1_grey, hi_grey, c(0.75,0.87), c(0.06,0.2), "Grey matter", "mean of estimates", "difference in estimates",  c(0.75,0.87), c(0.06,0.2))
blandplot(lo1_csf, hi_csf, c(0.03,0.15), c(-0.16,-0.03), "CSF", "mean of estimates", "difference in estimates", c(0.03,0.15), c(-0.16,-0.03))
blandplot(lo1_white, hi_white, c(0.05,0.20), c(-0.13,0.03), "White matter", "mean of estimates", "difference in estimates",  c(0.05,0.20), c(-0.13,0,0.03))
dev.off()

#compare lo1 and lo2 results
pdf('lo1_vs_lo2.pdf', width=6, height=6, title="lo1 vs lo2")
par(mfcol=c(2,2))
blandplot(lo1_grey, lo2_grey, c(0.8,0.95), c(-0.04,0.04), "Grey matter", "mean of estimates", "difference in estimates", c(0.8,0.95), c(-0.04,0,0.04))
blandplot(lo1_csf, lo2_csf, c(0,0.08), c(-0.015,0.01), "CSF", "mean of estimates", "difference in estimates", c(0,0.08), c(-0.015,0,0.01))
blandplot(lo1_white, lo2_white, c(0.03,0.18), c(-0.04,0.04), "White matter", "mean of estimates", "difference in estimates", c(0.03,0.18), c(-0.04,0,0.04))
dev.off()
