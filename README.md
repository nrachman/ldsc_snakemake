# ldsc snakemake workflow

A snakemake workflow to run the ldsc partitioning heritability analysis on predefined genomic regions.
https://github.com/bulik/ldsc

LD regression described in this publication:

Bulik-Sullivan, et al. LD Score Regression Distinguishes Confounding from Polygenicity in Genome-Wide Association Studies. Nature Genetics, 2015.

Baseline regions and partition heritability described in this publication:

Finucane, HK, et al. Partitioning heritability by functional annotation using genome-wide association summary statistics. Nature Genetics, 2015

## Input

bedfiles with your genomic regions of interest.

## Output

tsv file with results from ldsc partitioning heritability for each set of bed files.

All baseline regions appear in the output. The rows with L2_0 in the category column correspond to the enrichment results for the regions in your bedfile.

The results_filename column tells you which bed file that row corresponds to.

## Notes

Currently the partitioning h2 is run using the baseline regions from the first ld regression publication as covariates.

Currently only set up to calculate ld using phase 1 of 1000genomes

# Usage

To use conda with snakemake, I have had issues using the anaconda modules on the cluster, so I suggest installing your own instance of miniconda

### install miniconda

for linux
```
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh
```

I suggest preventing conda from always activating the base environment on start 
```
conda config --set auto_activate_base false
```

## To run the workflow

```
cd directory_where_you_want_to_save

git clone https://github.com/nrachman/ldsc_snakemake.git
```

Edit config.yaml to set "workingdir:" and the path to the bed files.

configure any additional options in sm_call.sh (not required)

## run

```
bash sm_call.sh
```
