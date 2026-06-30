#!/usr/bin/env Rscript
#source("/project/rv/scripts/activate.R")
library(optparse)
library(data.table)
library(R.utils)
# parse arguments
opt <- parse_args(OptionParser(
  option_list = list(
    make_option(
      "--outcomeGWAS",
      help = "Path to harmonised outcome GWAS file",
      default = ""
    )
  )
))
# import gzipped gwas outcome file
outcome_gwas_path <- opt$outcomeGWAS
gwas <- fread(file = outcome_gwas_path)
# export outcome file separated by chromosome
message("Exporting summary statistics as rdata split by chromosome")
lapply(unique(gwas$chromosome), \(x) {
  saveRDS(
    gwas[gwas$chromosome == x, ],
    file = paste0("chr", x, ".rds")
  )
})
