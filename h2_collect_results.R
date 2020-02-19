INPUT.PATHS <- snakemake@input
RESULTS.DAT.OUT.PATH <- snakemake@output[[1]]

results.list <- lapply(INPUT.PATHS, read.table, header=TRUE, sep="\t", nrows=1)
result.filenames <- sapply(INPUT.PATHS, basename)

for(i in seq_along(results.list)){
  stopifnot(identical(colnames(results.list[[1]]), colnames(results.list[[i]])))
  stopifnot(results.list[[i]]$category == "L2_0")
}

results.dat <- as.data.frame(do.call(rbind, results.list))
results.dat$result.filename <- result.filenames

write.table(results.dat, file=RESULTS.DAT.OUT.PATH, col.names=TRUE, row.names=FALSE, quote=FALSE, sep="\t")
