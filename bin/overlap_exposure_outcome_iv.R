#!/usr/bin/env Rscript
library(optparse)
opt <- parse_args(OptionParser(
  option_list = list(
    make_option("--clumpedIV"),
    make_option("--exposureID"),
    make_option("--outcomeID")
  )
))
iv <- opt$clumpedIV
exposure_id <- opt$exposureID
outcome_id <- opt$outcomeID

message(paste0("Running iv_union.R for exposure: ", exposure_id, " and outcome: ", outcome_id))

iv <- readRDS(iv)
# check if exposure IVs are present in outcome data
outcome <- lapply(unique(iv$chromosome), \(x) {
  readRDS(paste0("chr", x, ".rds"))
})
# rbind if list
outcome <- do.call(rbind, outcome)

iv_in_outcome <- subset(iv, variant_id %in% outcome$variant_id)
saveRDS(iv_in_outcome, paste0("exposure_IV.rds"))

outcome_snps <- subset(outcome, variant_id %in% iv_in_outcome$variant_id)
saveRDS(outcome_snps, paste0("outcome_IV.rds"))
