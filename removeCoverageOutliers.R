library(data.table)

args = commandArgs(trailingOnly=TRUE)

df=as.data.frame(fread(args[1]))

######################################################
# Use the code below to get 98th percentile
#######################################################

print (args[1])
print("BS")
print( quantile(df$V7, prob=0.98))


print("oxBS")
print( quantile(df$V10, prob=0.98))

belowCoverageThreshold = df[df$V7 < quantile(df$V7, prob=0.98) & df$V10 < quantile(df$V10, prob=0.98), ]
write.table(belowCoverageThreshold, paste0(args[1], ".outliers.removed.txt") , quote=F, col.names=F, row.names=F, sep="\t")

######################################################
# Use the code below to get mean + 2 standard deviations
#######################################################

#bs.threshold = summary(df[df$V7>=10 & df$V10>=10,]$V7)[4] + 2 * sd(df[df$V7>=10 & df$V10>=10,]$V7)
#oxbs.threshold = summary(df[df$V7>=10 & df$V10>=10,]$V10)[4] + 2 * sd(df[df$V7>=10 & df$V10>=10,]$V10)


#print (args[1])
#print(c(bs.threshold, oxbs.threshold))
#print("BS")
#print("Summary")
#print(summary(df[df$V7>=10 & df$V10>=10,]$V7))

#print("Standard Deviation")
#print(sd(df[df$V7>=10 & df$V10>=10,]$V7))

#print("oxBS")
#print("Summary")
#print(summary(df[df$V7>=10 & df$V10>=10,]$V10))

#print("Standard Deviation")
#print(sd(df[df$V7>=10 & df$V10>=10,]$V10))

#belowCoverageThreshold = df[df$V7 < bs.threshold & df$V10 < oxbs.threshold,]
#write.table(belowCoverageThreshold, paste0(args[1], ".outliers.removed.txt") , quote=F, col.names=F, row.names=F, sep="\t")
