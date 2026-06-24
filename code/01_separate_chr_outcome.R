library(data.table)
library(R.utils)
outcome_gwas_path <- "data/summary_stats_finngen_R13_M13_GIANTCELL.harmonised.gz"
gwas_dir <- "data/gwas_gca/"
gwas <- fread(file = outcome_gwas_path)
# create harmonised GWAS parquet file directory
if (!dir.exists(paste0(gwas_dir))) {
  dir.create(paste0(gwas_dir), recursive = TRUE, showWarnings = FALSE)
}

# export outcome data separated by chromosome
message("Exporting summary statistics as rdata split by chromosome")
lapply(unique(gwas$chromosome), \(x) {
  saveRDS(
    gwas[gwas$chromosome == x, ],
    file = paste0(gwas_dir, "/chr", x, ".rds")
  )
})
