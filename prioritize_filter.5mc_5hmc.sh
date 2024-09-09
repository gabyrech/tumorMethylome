file=$1
coverageMin=$2
methMin=$3
hmc=$4 # can either be "hmc" or anything else

if [ "$hmc" == "hmc" ]; then

	awk -v covMin=$coverageMin -v min=$methMin 'NR>1{if($7>=covMin && $10>=covMin && $4>=min){print $0}}' $file |  grep -v "NA" > $file.filtered.cov${coverageMin}.hmc${methMin}.bed

else

	awk -v covMin=$coverageMin -v min=$methMin '{if(($5 + $6)>=covMin && $4>=min){print $0}}' $file > $file.filtered.cov${coverageMin}.mc${methMin}.bed

fi
