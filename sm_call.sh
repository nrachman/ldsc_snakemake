#!/usr/bin/bash

module load snakemake

snakemake -j 1300 --cluster-config cluster_config.json --cluster "qsub -terse -l avx2,mem_free={cluster.mem_free},h_vmem={cluster.h_vmem} {cluster.parallel_opts}" -s Snakefile --use-conda
