# ldsc snakemake workflow

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

# To run the workflow

```
cd directory_where_you_want_to_save

git pull https://github.com/nrachman/ldsc_snakemake.git
```

Edit Snakefile to set "workingdir:" and the path to the bed files.

configure any additional options in sm_call.sh (not required)

# run

```
bash sm_call.sh
```
