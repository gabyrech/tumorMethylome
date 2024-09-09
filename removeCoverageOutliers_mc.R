library(data.table)

args = commandArgs(trailingOnly=TRUE)

df=as.data.frame(fread(args[1]))

######################################################
# Use the code below to get 98th percentile
#######################################################


print (args[1])
print("oxBS")
print( quantile(df$V7, prob=0.98))
belowCoverageThreshold = df[df$V7 < quantile(df$V7, prob=0.98), ]
write.table(belowCoverageThreshold, paste0(args[1], ".outliers.removed.txt") , quote=F, col.names=F, row.names=F, sep="\t")






######################################################
# Use the code below to get mean + 2 standard deviations
#######################################################


#oxbs.threshold = summary(df[df$V7>=10,]$V7)[4] + 2 * sd(df[df$V7>=10 ,]$V7)
#print(oxbs.threshold)

#print (args[1])
#print("oxBS")
#print("Summary")
#print(summary(df[df$V7>=10,]$V7))

#print("Standard Deviation")
#print(sd(df[df$V7>=10,]$V7))


#belowCoverageThreshold = df[df$V7 < oxbs.threshold ,]
#write.table(belowCoverageThreshold, paste0(args[1], ".outliers.removed.txt") , quote=F, col.names=F, row.names=F, sep="\t")
