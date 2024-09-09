#! /usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)
sample=args[1]

library(data.table)

# read in file of 5hmC per position annotated by gencode genes
hmc.genes.bed = as.data.frame(fread(paste0("hmc_conf_",sample, ".cov10.gencodeGeneList.bed")))
hmc.genes.bed$geneID = gsub("\\..*","", hmc.genes.bed$V16)

# manipulate this file to summarize the number of positions with 5hmC and the mean of the 5hmC
geneID.mean = aggregate(V4 ~ geneID, data = subset(hmc.genes.bed, V4>0), mean)
geneID.num = as.data.frame(table(subset(hmc.genes.bed, V4>0)$geneID))
geneID.mean.num = merge(geneID.mean, geneID.num, by.x = c("geneID"), by.y = c("Var1"))


geneID.numCovered = as.data.frame(table(hmc.genes.bed$geneID))
colnames(geneID.numCovered) = c("geneID", paste0(sample,".nCov"))
geneID.mean.num.cov = merge(geneID.mean.num, geneID.numCovered, by= c("geneID"), all=T)


# read in ensembl genes and merge with that list for ensembl gene names
geneList = read.table("gencode.ensembl.txt", header=T)

df = merge(geneID.mean.num.cov, geneList, by = "geneID")
colnames(df) = c("geneID", paste0(sample, ".mean"), paste0(sample,".count"), paste0(sample,".nCov"), "chr","start","end","geneName")
df[is.na(df)]=0

df$countPerCoveredC = df[,paste0(sample,".count")] / df[,paste0(sample,".nCov")]
df[is.na(df)]=0


write.table(df,paste0("hmc_conf", sample, ".summarizedByGene.txt"), col.names=T, row.names=F, sep='\t', quote=F)




