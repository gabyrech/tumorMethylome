#! /usr/bin/env Rscript

library(data.table)

args = commandArgs(trailingOnly=TRUE)

prefix=args[1]

bs = as.data.frame(fread(paste0("bis_", prefix,".cpg.autosomes.txt")))
ox = as.data.frame(fread(paste0("oxbis_", prefix, ".cpg.autosomes.txt")))

colnames(bs) = c("chr","start","end","percent.bs","meth.bs","nometh.bs")
colnames(ox) = c("chr","start","end","percent.ox","meth.ox","nometh.ox")

both = merge(bs,ox,by=c("chr","start","end"))

attach(both)
ans = lapply(seq_along(meth.bs), function(j) 
        prop.test(c(meth.bs[j], meth.ox[j]), c(meth.bs[j] + nometh.bs[j], meth.ox[j] + nometh.ox[j])))
detach (both)
        
pval = sapply(ans, '[[', 'p.value')
both$pval = pval
both$hmc = both$meth.bs/(both$meth.bs + both$nometh.bs) - both$meth.ox/(both$nometh.ox + both$meth.ox)

both$sum = both$meth.bs + both$nometh.bs + both$nometh.ox + both$meth.ox
both = subset(both, sum>=20) # confident and significant calls both require more than 20 reads in bs +ox
both$totalReads.bs = both$meth.bs+both$nometh.bs
both$totalReads.ox = both$meth.ox+both$nometh.ox
both$hmc.percent = both$hmc * 100
both.sig = both[both$pval<0.05 & both$hmc > 0, ]

both.sig.small = both.sig[,c("chr","start","end","hmc.percent","meth.bs","nometh.bs","totalReads.bs","meth.ox","nometh.ox","totalReads.ox")]

write.table(as.data.frame(both.sig.small),file=paste0("hmc_sig_", prefix ,".cpg.txt"),col.names = T,row.names=FALSE, quote=FALSE, sep = "\t")


zeros = subset(both,(pval>=0.05|(percent.bs == percent.ox & (percent.ox == 0 | percent.bs ==100))))   
zeros$hmc[zeros$hmc!=0] =0

conf =rbind(both.sig, zeros)


conf$totalReads.bs = conf$meth.bs+conf$nometh.bs
conf$totalReads.ox = conf$meth.ox+conf$nometh.ox
conf$hmc.percent = conf$hmc * 100
conf.small = conf[,c("chr","start","end","hmc.percent","meth.bs","nometh.bs","totalReads.bs","meth.ox","nometh.ox","totalReads.ox")]

write.table(as.data.frame(conf.small),file=paste0("hmc_conf_", prefix ,".cpg.txt"),col.names = T,row.names=FALSE, quote=FALSE, sep = "\t")
