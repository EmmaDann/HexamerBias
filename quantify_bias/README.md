## QUANTIFICATION AND VISUALIZATION OF COVERAGE BIASES

### Contents
* `biasProfiles.r`: R functions to plot average coverage profiles over annotated regions
* `figure1.Rmd`: R notebook of plots for figure 1 in report (biased primer usage)
* `make_profile.sh`: script to calculate coverage profiles over annotated regions (hard coded to work on genes or long regions with variable length. Change to reference-point to compute coverage over specific sites)
* `multi_cov_profiles_VAN2591.Rmd`: R notebook for comparison of coverage bias in different samples (BS and non BS converted, different genomes)
***
### How to make coverage profile across coding regions
```
make_profile.sh <sample.bam> <refseq_genes.bed>
```
Output is a `.mat.gz` file that is a matrix of coverage over an equal set of bins for each gene.

### How to plot coverage profile
From the make profile you will get a ```sample.mat.gz``` file.

In R:
```
source("/hpc/hub_oudenaarden/edann/bin/coverage_bias/biasProfiles.r")
profile.smp1 <- load.matrix('~/path/to/file/sample1.mat.gz')
profile.smp2 <- load.matrix('~/path/to/file/sample2.mat.gz')

df <- make.df.of.profiles(list(label_4_smp1 = profile.smp2, label_4_smp2 = profile.smp2 ))
plot.refpoint.profile.df(df, center='the name for the center', color='the label for the legend')
```
**N.B.**: the profiles are normalized as Z-scores!

Alternatively you can use the plotting function from `deepTools`:
```
plotProfile -m sample1.mat.gz  \
              -out outfile.png \
              --numPlotsPerRow 1 \
              --yAxisLabel "coverage" \
              --regionsLabel samplename
```
But the plots are ugly and the normalization obscure.

<!-- ## Bias for TSS and exons
From the coverage bigWig file obtained with ```bamCoverage``` (see artificial coverage) I make a profile of the most covered regions, using deepTools.
```
computeMatrix scale-regions \
  -R  regions_of_interest.bed \
  -S sample_coverage.bw \
  -b 3000 -a 3000 --regionBodyLength 5000 --skipZeros \
  -o sample_coverage.mat.gz
```
make the profile with deepTools:
```
plotProfile -m sample_coverage.mat.gz  \
              -out outfile.png \
              --numPlotsPerRow 1 \
              --yAxisLabel "coverage" \
              --regionsLabel samplename
```
or use functions in Rscript ```biasProfiles.r```

One liner to get average over columns (ready to plot in R)
```
zcat ${sample}.mat.gz  |
  awk '{for (i=1;i<=NF;i++) if (i>=7) printf("%s ", $i); print ""}' | # Removes first 6 cols
  awk '{ for(i=1;i<=NF;i++) {total[i]+=$i ;} }
  END {
     for(i=1;i<=NF;i++) printf "%f ",total[i]/NR ;
     printf "\n" }' >  ${sample}.profile.txt
```

## Comparison with non-PBAT BS-seq
The best I could find now is the data from the scWGBS protocol (Farlik et al. 2014). Downloaded from https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE65196 -->
