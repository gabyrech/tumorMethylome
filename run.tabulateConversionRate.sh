sample=$1

echo "
#PBS -l nodes=1:ppn=12
#PBS -l walltime=4:00:00
#PBS -q batch
#PBS -N $sample.run.tabulateConversionRate
#PBS -V
#PBS -m ae
cd \$PBS_O_WORKDIR

sh /projects/wei-lab/cfDNA/analysis/scripts/tabulateConversionRate.sh $sample.bis.sort.mDups_CHH.bedGraph
sh /projects/wei-lab/cfDNA/analysis/scripts/tabulateConversionRate.sh $sample.oxbis.sort.mDups_CHH.bedGraph

rm $sample.bis.sort.mDups_CHH.bedGraph $sample.oxbis.sort.mDups_CHH.bedGraph

" >$sample.run.tabulateConversionRate.sh

