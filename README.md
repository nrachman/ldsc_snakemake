To use conda with snakemake, I have had issues using the anaconda modules on the cluster, so I suggest installing your own instance of miniconda

install miniconda

for linux
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh

I suggest preventing conda from always activating itself
conda config --set auto_activate_base false

#To run the workflow
git pull 

Set working directory and the path to the bed files in Snakefile.

configure any options in sm_call.sh

#To run
bash sm_call.sh
