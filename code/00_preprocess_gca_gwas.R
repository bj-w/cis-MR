library(data.table)
library(R.utils) # to read gz files
library(tidyverse)

gwas <- fread(
  "raw_data/gca_gwas/summary_stats_finngen_R13_M13_GIANTCELL.gz"
)
# create harmonised GWAS parquet file directory
gwas_dir <- "data/gwas_gca/"
if (!dir.exists(paste0(gwas_dir))) {
  dir.create(paste0(gwas_dir), recursive = TRUE, showWarnings = FALSE)
}
# formatting
colnames(gwas)[colnames(gwas) == "#chrom"] <- "chromosome"
# export gwas parquet files
message("Exporting summary statistics as rdata")
map(unique(gwas$chromosome), \(x) {
  saveRDS(
    filter(gwas, chromosome == x),
    file = paste0(gwas_dir, "/chr", x, ".rds")
  )
})
