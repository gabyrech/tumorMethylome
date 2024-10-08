# tumorMethylome
This repository contains commands and scripts used for analyzing methylation data (bisulfite and oxidative bisulfite sequencing (BS/oxBS-seq)) in the article **Global DNA methylome analyses uncover cancer-associated 5hmC signatures preferentially detected in patients’ cell-free DNA**.

Methods described below were conceived, developed and implemented by Rachel Goldfeder and Gabriel E. Rech.

# Dependencies
* bwa
* bwa-meth
* samtools 0.7.12
* python 2.7.3
* bedtools 2.17.0
* R
* biscuit v0.2
* MethylDackel 0.3.0

# Input data

```bash
bis_fq1= # Bisulfite sequencing R1 fastq file. 
bis_fq2= # Bisulfite sequencing R2 fastq file. 
oxbis_fq1= # Oxidative Bisulfite sequencing R1 fastq file. 
oxbis_fq2= # Oxidative Bisulfite sequencing R2 fastq file. 
outPrefix= # Sample prefix
ref= # Reference Genome (E.g. Homo_sapiens.GRCh38.dna.primary_assembly.fa}
```

# 1. Align reads with BWA-Meth
```bash
$ bwameth.py  --threads 24 --reference $ref $bis_fq1 $bis_fq2 > $outPrefix.bis.sam
$ bwameth.py  --threads 24 --reference $ref $oxbis_fq1 $oxbis_fq2 > $outPrefix.oxbis.sam
```

# 2. Process Aligned Reads & QC
```bash
$ samtools view -S -b $outPrefix.bis.sam > ${outPrefix}.bis.bam
$ rm $outPrefix.bis.sam
$ samtools sort -@ 11 ${outPrefix}.bis.bam > ${outPrefix}.bis.sort.bam
$ rm $outPrefix.bis.bam
$ samtools index ${outPrefix}.bis.sort.bam
$ samtools flagstat ${outPrefix}.bis.sort.bam > ${outPrefix}.bis.flagstat
```
```bash
$ samtools view -S -b $outPrefix.oxbis.sam > ${outPrefix}.oxbis.bam
$ rm $outPrefix.oxbis.sam
$ samtools sort -@ 11 ${outPrefix}.oxbis.bam > ${outPrefix}.oxbis.sort.bam
$ rm $outPrefix.oxbis.bam
$ samtools index ${outPrefix}.oxbis.sort.bam
$ samtools flagstat ${outPrefix}.oxbis.sort.bam > ${outPrefix}.oxbis.flagstat
```
# 3. Mark duplicates with biscuit & QC

```bash
$ biscuit markdup ${outPrefix}.bis.sort.bam  ${outPrefix}.bis.mDups.bam
$ samtools sort ${outPrefix}.bis.mDups.bam > ${outPrefix}.bis.sort.mDups.bam
$ rm ${outPrefix}.bis.mDups.bam
$ samtools flagstat ${outPrefix}.bis.sort.mDups.bam > ${outPrefix}.bis.mdups.flagstat
```
```bash
$ biscuit markdup ${outPrefix}.oxbis.sort.bam  ${outPrefix}.oxbis.mDups.bam
$ samtools sort ${outPrefix}.oxbis.mDups.bam > ${outPrefix}.oxbis.sort.mDups.bam
$ rm ${outPrefix}.oxbis.mDups.bam 
$ samtools flagstat ${outPrefix}.oxbis.sort.mDups.bam > ${outPrefix}.oxbis.mdups.flagstat
```

# 4. Call methylation with MethylDackel
```bash
$ MethylDackel extract -l Homo_sapiens.GRCh38.dna.primary_assembly.fa.allcpg_parsed.bed -@ 12 $ref ${outPrefix}.bis.sort.mDups.bam
$ MethylDackel extract --CHH --noCpG -@ 12  $ref  ${outPrefix}.bis.sort.mDups.bam 
```
```bash
$ MethylDackel extract  -l  Homo_sapiens.GRCh38.dna.primary_assembly.fa.allcpg_parsed.bed -@ 12  $ref  ${outPrefix}.oxbis.sort.mDups.bam 
$ MethylDackel extract --CHH  --noCpG -@ 12 $ref ${outPrefix}.oxbis.sort.mDups.bam 
```
```bash
$ sh run.tabulateConversionRate.slurm.sh ${outPrefix}
```

# 5. Make plots for distributions of coverage for bs and ox + basic QC

```bash
Rscript process_cov_bs_oxbs.R $sampleDir $outPrefix ${outPrefix}.bis.sort.mDups_CpG.bedGraph $outPrefix.oxbis.sort.mDups_CpG.bedGraph
```

# 6. Calculate 5hmC for CpG level
### Calculates 5hmC Chi-Squared test and outputs confident and significant 5hmc. Then, plot the distribution of methylation levels for significant 5hmC
```bash
$ Rscript calc_cpg_5hmC.R $outPrefix
```
```bash
$ Rscript single_cpg_plot.R $outPrefix
```

# 7. Filter 5hmC results based on coverage  
```bash
$ minCov= # Define minimun requiered coverage. In the paper we use 10 for tissues and 7 for cfDNA.
$ sh prioritize_filter.5mc_5hmc.sh hmc_conf_${outPrefix}.cpg.txt $minCov 0 hmc
$ sh prioritize_filter.5mc_5hmc.sh oxbis_${outPrefix}.cpg.autosomes.txt $minCov 0 mc

$ Rscript removeCoverageOutliers.R  hmc_conf_${outPrefix}.cpg.txt.filtered.cov10.hmc0.bed
$ Rscript removeCoverageOutliers_mc.R  $outPrefix.oxbis.sort.mDups_CpG.bedGraph.CpG.txt.filtered.cov10.mc0.bed
```

# 8. Overlap with Genes; calculate 5hmC counts and mean for each gene 
```bash
$ bedtools intersect -a hmc.conf.${outPrefix}.cpg.filtered.cov10.hmc0.autosomes.bed -b gene+-1kb.gencode.v27.annotation.keepBiotype.all.bed -wao > hmc_conf_${outPrefix}.cov10.gencodeGeneList.temp.bed
$ grep genebody_plus1kb hmc_conf_${outPrefix}.cov10.gencodeGeneList.temp.bed > hmc_conf_${outPrefix}.cov10.gencodeGeneList.bed
$ rm hmc_conf_${outPrefix}.cov10.gencodeGeneList.temp.bed
$ Rscript calc5hmCPerGene.R $outPrefix 
```




