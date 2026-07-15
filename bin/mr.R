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


# format
exp <- format_data(
  data.frame(exp),
  type = "exposure",
  snp_col = "variant_id",
  beta_col = "beta",
  se_col = "standard_error",
  eaf_col = "effect_allele_frequency",
  effect_allele_col = "effect_allele",
  other_allele_col = "other_allele",
  pval_col = "p_value"
)

out <- format_data(
  data.frame(out),
  type = "outcome",
  snp_col = "variant_id",
  beta_col = "beta",
  se_col = "standard_error",
  eaf_col = "effect_allele_frequency",
  effect_allele_col = "effect_allele",
  other_allele_col = "other_allele",
  pval_col = "p_value"
)

# harmonise
harm <- harmonise_data(exp, out)
write.csv(
  harm,
  paste0(exposure_id, ".IV_harmonised.csv"),
  row.names = FALSE
)

# MR
mr_results <- mr(harm)
write.csv(
  mr_results,
  paste0(exposure_id, ".mr_results.csv"),
  row.names = FALSE
)
