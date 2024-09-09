args = commandArgs(trailingOnly=TRUE)


library(data.table)

sampName = args[2]

#methCalls = getwd()

setwd( paste0(args[1]) )


bs = as.data.frame(fread(args[3],header=TRUE))
ox = as.data.frame(fread(args[4],header=TRUE))

colnames(bs)=c("chr","start","end","percentMethylated.bs","meth.bs","nometh.bs")
colnames(ox)=c("chr","start","end","percentMethylated.ox","meth.ox","nometh.ox")

bs$all=bs$meth.bs + bs$nometh.bs
ox$all=ox$meth.ox + ox$nometh.ox

bs = subset(bs, chr=="1"|chr=="2"|chr=="3"|chr=="4"|chr=="5"|chr=="6"|chr=="7"|chr=="8"|chr=="9"|chr=="10"|chr=="11"|chr=="12"|chr=="13"|chr=="14"|chr=="15"|chr=="16"|chr=="17"|chr=="18"|chr=="19"|chr=="20"|chr=="21"|chr=="22")
ox = subset(ox, chr=="1"|chr=="2"|chr=="3"|chr=="4"|chr=="5"|chr=="6"|chr=="7"|chr=="8"|chr=="9"|chr=="10"|chr=="11"|chr=="12"|chr=="13"|chr=="14"|chr=="15"|chr=="16"|chr=="17"|chr=="18"|chr=="19"|chr=="20"|chr=="21"|chr=="22")

bs = droplevels(bs)
ox = droplevels(ox)

#setwd(methCalls)

write.table(as.data.frame(bs), file=paste0("bis_",sampName,".cpg.autosomes.txt"), col.names = T, row.names=FALSE, quote=FALSE, sep = "\t")
write.table(as.data.frame(ox), file=paste0("oxbis_",sampName,".cpg.autosomes.txt"), col.names = T, row.names=FALSE, quote=FALSE, sep = "\t")

bs.coverage.table = table(bs$all)
ox.coverage.table = table(ox$all)

bs.table.df = as.data.frame(bs.coverage.table)
ox.table.df = as.data.frame(ox.coverage.table)

bs.table.df$percent = (100*(bs.table.df$Freq/(55705478)))
ox.table.df$percent = (100*(ox.table.df$Freq/(55705478)))

bs.table.df = bs.table.df[-c(1),]
ox.table.df= ox.table.df[-c(1),]


#setwd("../meth_calls/plots")

pdf(paste0(sampName,".covDistribution.pdf"))
plot(bs.table.df$percent, xlim = c(0,25), ylim = c(0,25), type="h", xlab="coverage", ylab="%", lwd = 4, col=rgb(0,.5,0,1/4))
par(new=TRUE)
plot(ox.table.df$percent, xlim = c(0,25), ylim = c(0,25), type="h", xlab="coverage", ylab="%", lwd = 4, col=rgb(0,0,.5,1/4)) 
dev.off()


perc.mat=matrix(nrow=10,ncol=3)
for (i in 1:10) {
	perc.bs=nrow(subset(bs,all>=i))/55705478
	perc.ox=nrow(subset(ox,all>=i))/55705478
	perc.mat[i,1]= i
	perc.mat[i,2]=perc.bs
	perc.mat[i,3]=perc.ox 
}


colnames(perc.mat) = c("cov","BS CpG percent","oxBS CpG percent")
write.table(perc.mat, paste0(sampName, "_distributionOfCoverageForCpGs.txt"),row.names=FALSE, quote=FALSE,sep="\t")
