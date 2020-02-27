configfile: "config.yaml"
workdir: config['workdir']

#Inputs
#Path to input bed files. 
BED_IN_DIR = config['bed_in_dir']

#Outputs
#The output of make_annot and ld_scores will be saved to /ldsc_out
#  This includes the .annot files, as well as all .ld* files
#The output of partition_h2 will be saved to /h2_out
#  This is both the .results and the .log files
#The compiled output tsv file with baseline adjusted coefficients and p values will be saved /h2_compiled

#LDSC Config
#Directories where ldsc scripts and required external data are saved
LDSC_SCRIPTS_DIR = config['ldsc_scripts_dir']
LDSC_DATA_DIR = config['ldsc_data_dir']
SUMSTATS_DIR = config['sumstats_dir']

#Set chromosome numbers- used for iterating over chromosomes
CHROM_NUMBERS = range(1,23) 

#Read in names of all of the input bedfiles. These will be used for iterating
import os
PEAK_GROUPS = os.listdir(BED_IN_DIR)
#remove file extension and just keep name
for i in range(0, len(PEAK_GROUPS)):
    PEAK_GROUPS[i] = os.path.splitext(PEAK_GROUPS[i])[0]
#PEAK_GROUPS = PEAK_GROUPS[0:1] #for testing on subset
 
#Read in names of all of the gwas studies
GWAS_STUDIES = os.listdir(SUMSTATS_DIR)
GWAS_STUDIES = list(filter(lambda x:'sumstats' in x, GWAS_STUDIES))
#remove file extension and just keep name
for i in range(0, len(GWAS_STUDIES)):
     GWAS_STUDIES[i] = os.path.splitext(GWAS_STUDIES[i])[0]
#GWAS_STUDIES = GWAS_STUDIES[0:2] #for testing on subset

#Define targets of entire workflow
rule all:
    input:
        # The commented out portions are the intermediate outputs from each rule. They will still be generated despite being commented out.
        #expand("ldsc_out/{peak_group}.{chrom_number}.annot.gz", peak_group=PEAK_GROUPS, chrom_number=CHROM_NUMBERS)
        #expand("ldsc_out/{peak_group}.{chrom_number}.l2.ldscore.gz", peak_group=PEAK_GROUPS, chrom_number=CHROM_NUMBERS)
        #expand("h2_out/{peak_group}.{gwas_study}.results", peak_group=PEAK_GROUPS, gwas_study=GWAS_STUDIES)
        "h2_compiled_results/results_dat.tsv"

###Make annotations
#These need to be output to the same directory as the ld scores or else partition_h2 won't work
rule make_annot:
    input:
        bed="{bed_in_dir}/{{peak_group}}.bed".format(bed_in_dir = BED_IN_DIR),
        bim="{ldsc_data_dir}/1000G_EUR_Phase3_plink/1000G.EUR.QC.{{chrom_number}}.bim".format(ldsc_data_dir = LDSC_DATA_DIR)
    output:
        annot="ldsc_out/{peak_group}.{chrom_number}.annot.gz"
    conda:
        "{ldsc_scripts_dir}/environment.yml".format(ldsc_scripts_dir = LDSC_SCRIPTS_DIR)
    shell:
        "python {ldsc_scripts_dir}/make_annot.py"
        "  --bed-file  {{input.bed}}"
        "  --bimfile  {{input.bim}}"
        "  --annot-file {{output}}".format(ldsc_scripts_dir = LDSC_SCRIPTS_DIR)  


###Compute LD scores with annot file
##have to do some weird things with the --bfile and --out because ldsc.py automatically adds file extensions
# It is very important to include the print_snps flag with the proper print_snps.txt. This print_snps.txt is#
# present in the 1000G_EUR_Phase3_baseline ftp. If this isn't used, you will get an error saying that the ldscores 
# files don't have the same snp columns as the baseline
rule ld_scores:
    input:
        annot="ldsc_out/{peak_group}.{chrom_number}.annot.gz",
        snps="{ldsc_data_dir}/1000G_EUR_Phase3_baseline/print_snps.txt".format(ldsc_data_dir = LDSC_DATA_DIR)
    output:
        "ldsc_out/{peak_group}.{chrom_number}.l2.ldscore.gz"
    conda:
        "{ldsc_scripts_dir}/environment.yml".format(ldsc_scripts_dir = LDSC_SCRIPTS_DIR)
    shell:
        "python {ldsc_scripts_dir}/ldsc.py"
        " --l2"
        " --bfile {ldsc_data_dir}/1000G_EUR_Phase3_plink/1000G.EUR.QC.{{wildcards.chrom_number}}"
        " --ld-wind-cm 1"
        " --annot {{input.annot}}"
        " --thin-annot"
        " --out ldsc_out/{{wildcards.peak_group}}.{{wildcards.chrom_number}}"
        " --print-snps {{input.snps}}".format(ldsc_data_dir = LDSC_DATA_DIR, ldsc_scripts_dir = LDSC_SCRIPTS_DIR)

###Perform partitioning of heritability
#annot need to be output to the same directory as the ld scores or else partition_h2 won't work
rule partition_h2:
    input:
        ss="{sumstats_dir}/{{gwas_study}}.sumstats".format(sumstats_dir = SUMSTATS_DIR), 
        ref_ld_chr=expand("ldsc_out/{{peak_group}}.{chrom_number}.l2.ldscore.gz", chrom_number=CHROM_NUMBERS)
    output:
        "h2_out/{peak_group}.{gwas_study}.results"
    conda:
        "{ldsc_scripts_dir}/environment.yml".format(ldsc_scripts_dir = LDSC_SCRIPTS_DIR)
    shell:
        "python {ldsc_scripts_dir}/ldsc.py"
        "  --h2 {{input.ss}}"
        "  --ref-ld-chr ldsc_out/{{wildcards.peak_group}}.,{ldsc_data_dir}/1000G_EUR_Phase3_baseline/baseline."
        "  --overlap-annot"
        "  --frqfile-chr {ldsc_data_dir}/1000G_Phase3_frq/1000G.EUR.QC."
        "  --out h2_out/{{wildcards.peak_group}}.{{wildcards.gwas_study}}"
        "  --w-ld-chr {ldsc_data_dir}/weights_hm3_no_hla/weights."
        "  --print-coefficients".format(ldsc_data_dir = LDSC_DATA_DIR, ldsc_scripts_dir = LDSC_SCRIPTS_DIR)

# Takes all of the results from partition_h2 and puts them into single file
rule h2_collect_results:
    input:
        expand("h2_out/{peak_group}.{gwas_study}.results", peak_group=PEAK_GROUPS, gwas_study=GWAS_STUDIES)
    output:
        "h2_compiled_results/results_dat.tsv"
    script:
        "h2_collect_results.py"
