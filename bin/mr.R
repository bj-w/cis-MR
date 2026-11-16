#!/usr/bin/env Rscript
library(TwoSampleMR)
args <- commandArgs(trailingOnly = TRUE)
exposure_id <- args[1]
exp_iv <- args[2]
outcome_id <- args[3]
out_iv <- args[4]

message("Running MR for exposure: ", exposure_id, " and outcome: ", outcome_id)
message("files: ", exp_iv, " and ", out_iv)


exp <- readRDS(exp_iv)
out <- readRDS(out_iv)

# harmonise
harm <- harmonise_data(exp, out)
saveRDS(
  harm,
  paste0(exposure_id, ".IV_harmonised.rds")
)

# MR
mr_results <- mr(harm)
saveRDS(
  mr_results,
  paste0(exposure_id, ".mr_results.rds")
)
