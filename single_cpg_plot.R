#! /usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)
 
sample.name=args[1]

library(data.table)

a=as.data.frame(fread(paste0("hmc_sig_",sample.name,".cpg.txt"), header=T))
#setwd("../meth_calls/plots")
histPercent <- function(i, ...) {
   H <- hist(i, plot = FALSE)
   H$density <- with(H, 100 * density* diff(breaks)[1])
   labs <- paste(round(H$density), "%", sep="")
   plot(H, freq = FALSE, labels = labs, ylim=c(0, 1.08*max(H$density)),...)
}

pdf(paste0("hmc.",sample.name,".significant.cpg.hist.pdf"))
histPercent(a$hmc.percent,col=rgb(0.128,0.128,0.128,1/4),main = paste0("Histogram of % 5hmC CpG methylation: ",sample.name),xlab="% hmC per base")
dev.off()
