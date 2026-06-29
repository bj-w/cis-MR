#!/usr/bin/env Rscript
source("/project/rv/scripts/activate.R")
library(optparse)
opt <- parse_args(OptionParser(
  option_list = list(
    make_option("--clumpedIV"),
    make_option("--exposureID")
  )
))
iv <- opt$clumpedIV
exposure_id <- opt$exposureID

iv <- readRDS(iv)
# check if exposure IVs are present in outcome data
outcome <- lapply(unique(iv$chromosome), \(x) {
  readRDS(paste0("chr", x, ".rds"))
})
# rbind if list
outcome <- do.call(rbind, outcome)

iv_in_outcome <- subset(iv, variant_id %in% outcome$variant_id)
saveRDS(iv_in_outcome, paste0(exposure_id, ".exposure_IV.rds"))

outcome_snps <- subset(outcome, variant_id %in% iv_in_outcome$variant_id)
saveRDS(outcome_snps, paste0(exposure_id, ".outcome_IV.rds"))
