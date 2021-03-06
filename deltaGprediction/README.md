## DNA-DNA BINDING MODEL
Scripts for implementation of model for primer binding, including
* Data preprocessing (counting genomic kmer abundance, construction of primer-template count matrix) (in bash and python)
* estimation of association constants and scaling factor epsilon (in R)
* coverage prediction (in R)

***

### Contents
* `old_modelling`: includes scripts for the first version of the model (delta G prediction)
* `Rnotebooks`: includes all notebooks for exploratory data analysis, modelling and data visualization on different datasets
* `binding_model_functions.r`: helper R functions for implementation of the model (initial data manipulation, modelling, plotting)
* `bsPrimerTemplateTab.py`: builds primer-template tab from fasta file of untrimmed reads and fasta of template sequences
* `build_pt_matrix.sh`: wrapper for construction of primer-template matrix (calls the necessary python scripts)
* `epsilon_downsampling.r`: script for epsilon estimation on downsampled bam files
* `getPrimedRegion.py`: extracts template sequences from bam files, in fasta format
* `kmersInGenome.sh`: calls kmer-counter to compute hexamer abundance in region of interest
* `run_cov_prediction_BS.r`: runs coverage prediction in BS-seq samples (makes K estimation on random batch and does prediction for all primer concentration)
* `run_epsilon_estimation.r`: makes chi-square estimation of epsilon from .RDS table for sample

***
### How to compute genomic hexamer abundance
```
kmersInGenome.sh reference_genome.fa
```
Calls `kmerCounter.py` from `HexamerBias/utils`, by default using 8 cores (Ask for them when submitting). Output is `reference_genome.kmerAbundance.csv`.

### How to build primer-template count matrix
#### Without wrapper
1. Extract template sequences from alignment file and reference genome:
```
python getPrimedRegion.py -o <output_directory> -s <bamfile> <reference_genome_fasta>
```
Outputs bed file of coordinates of templates and fasta file that stores template sequences for every aligned read with high quality primer sequence (read name is in the header).
**WRONG QUALITY FILTERING**

**N.B.** The script builds the bed file if it doesn't find it in the folder. Please make sure you have no other bed file with the same name in the working directory before running the script. If the script crashes for any reason (e.g. no space left, malformed bed entries...) make sure you delete the output bed before rerunning, or you will get an empty fasta (I could fix this, I know).

Run `python getPrimedRegion.py -h` for file formats and further options.

2. Build primer template matrix from untrimmed reads and template sequences:
```
python bsPrimerTemplTab.py -t <datatype> <untrimmedreads.fastq> <templates.fa> <genomic_kmer_abundance>
```
Outputs a csv file of the matrix.

Run `python bsPrimerTemplTab.py -h` for file formats and further options.

#### With wrapper
Use the wrapper `build_pt_matrix.sh`. Takes as input:
1. Mapped reads (bam file) of sample of interest
2. Reference genome (fasta file)
3. Untrimmed reads of sample of interest (fastq file)
4. Data type of input bam: for BS-seq single-end mapped (bs_se), BS-seq paired-end mapped (bs_pe), WGS (no_bs)

**N.B.** This reads a folder in my directory on the cluster where I have stored all the genomic kmer abundances for a number of genomes, not sure if other users can read them.

**N.B. IN ALL MATRIXES TEMPLATES ARE IN ROWS AND PRIMERS ARE IN COLUMNS**  
