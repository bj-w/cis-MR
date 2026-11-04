#!/usr/bin/env Rscript
library(TwoSampleMR)
args <- commandArgs(trailingOnly = TRUE)
exposure_id <- args[1]
exp_iv <- args[2]
outcome_id <- args[3]
out_iv <- args[4]

message("Running MR for exposure: ", exposure_id, " and outcome: ", outcome_id)
message("files: ", exp_iv, " and ", out_iv)


# import exposure and outcome files --------------------------------------
exp <- readRDS(exp_iv)
out <- readRDS(out_iv)


# format exposure --------------------------------------------------------
exp <- format_data(
  data.frame(exp),
  type = "exposure",
  snp_col = "rsid",
  beta_col = "beta",
  se_col = "standard_error",
  eaf_col = "effect_allele_frequency",
  effect_allele_col = "effect_allele",
  other_allele_col = "other_allele",
  pval_col = "p_value"
)


# format outcome ---------------------------------------------------------
# explicitly use harmonised columns. SE and P-value ok.
out <- format_data(
  data.frame(out),
  type = "outcome",
  snp_col = "hm_rsid",
  beta_col = "hm_beta",
  se_col = "standard_error",
  eaf_col = "hm_effect_allele_frequency",
  effect_allele_col = "hm_effect_allele",
  other_allele_col = "hm_other_allele",
  pval_col = "p_value"
)


# harmonise --------------------------------------------------------------
harm <- harmonise_data(exp, out)
saveRDS(
  harm,
  paste0(exposure_id, ".IV_harmonised.rds")
)


# run MR -----------------------------------------------------------------
mr_results <- mr(harm)
saveRDS(
  mr_results,
  paste0(exposure_id, ".mr_results.rds")
)
