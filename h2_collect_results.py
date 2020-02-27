import pandas as pd
import os 

INPUT_PATHS=snakemake.input
OUT_DAT_PATH=snakemake.output[0]

#for testing
#INPUT_PATHS= []
#h2_dir = "/hpcdata/sg/sg_data/users/rachmaninoffn2/scratch/h2_test/h2_out/"
#OUT_DAT_PATH= "/hpcdata/sg/sg_data/users/rachmaninoffn2/scratch/h2_test/h2_compiled_results/pandas_test.tsv"
#all_files = os.listdir(h2_dir)
#
#for file in all_files:
#    if file.endswith(".results"):
#        INPUT_PATHS.append(h2_dir + "/" + file)


#read in data
df_list = []
for path in INPUT_PATHS:
    df = pd.read_csv(path, sep = "\t")
    df = df.assign(results_filename = os.path.basename(path))
    df_list.append(df)


#append into single dataframe
n_df = len(df_list)

out_df = df_list[0]
for i in range(1, n_df):
    out_df=out_df.append(df_list[i])

#write dataframe out
out_df.to_csv(OUT_DAT_PATH, sep = "\t", index = False)

