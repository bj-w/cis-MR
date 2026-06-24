library(TwoSampleMR)

exposure_file <- "4496_60_MMP12_MMP_12"
exposure_id <- "MMP12"
exp <- readRDS(paste0("data/", exposure_file, ".exposure_SNPs.rds"))
out <- readRDS(paste0("data/", exposure_file, ".outcome_SNPs.rds"))
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

out <- format_data(
  data.frame(out),
  type = "outcome",
  snp_col = "snp_id",
  beta_col = "beta",
  se_col = "sebeta",
  eaf_col = "af_alt",
  effect_allele_col = "alt",
  other_allele_col = "ref",
  pval_col = "pval"
)

harm <- harmonise_data(exp, out)
write.csv(
  harm,
  paste0("output/", exposure_file, ".IV_harmonised.csv"),
  row.names = FALSE
)
mr_results <- mr(harm)
write.csv(
  mr_results,
  paste0("output/", exposure_file, ".mr_results.csv"),
  row.names = FALSE
)
