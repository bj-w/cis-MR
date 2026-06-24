exposure_file <- "4496_60_MMP12_MMP_12"
exposure_id <- "MMP12"
outcome_dir <- "data/gwas_gca/"
iv <- readRDS(paste0("data/", exposure_file, ".iv.ld_clumped.rds"))
# check if exposure IVs are present in outcome data
outcome <- lapply(unique(iv$chromosome), \(x) {
  readRDS(paste0(outcome_dir, "chr", x, ".rds"))
})
# rbind if list
outcome <- do.call(rbind, outcome)

iv_in_outcome <- subset(iv, variant_id %in% outcome$variant_id)
saveRDS(iv_in_outcome, paste0("data/", exposure_file, ".exposure_SNPs.rds"))

outcome_snps <- subset(outcome, variant_id %in% iv_in_outcome$variant_id)
saveRDS(outcome_snps, paste0("data/", exposure_file, ".outcome_SNPs.rds"))
