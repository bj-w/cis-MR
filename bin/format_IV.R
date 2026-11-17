#!/usr/bin/env Rscript
library(optparse)
library(tidyverse)
library(TwoSampleMR)
library(ieugwasr)
library(gwasvcf)

# arguments --------------------------------------------------------------
opt <- parse_args(OptionParser(
  option_list = list(
    make_option("--clumpedIV"),
    make_option("--initialIV"),
    make_option("--exposureID"),
    make_option("--outcomeID"),
    make_option("--ldProxyR2"),
    make_option("--bfilePaths"),
    make_option("--p1clump"),
    make_option("--r2clump"),
    make_option("--kbclump"),
    make_option("--snpCol"),
    make_option("--betaCol"),
    make_option("--seCol"),
    make_option("--pvalCol"),
    make_option("--eafCol"),
    make_option("--effectAlleleCol"),
    make_option("--otherAlleleCol")
  )
))
exposure <- opt$clumpedIV
exposure_id <- opt$exposureID
exposure_initial <- opt$initialIV
outcome_id <- opt$outcomeID
ld_proxy_r2 <- as.numeric(opt$ldProxyR2)
bfile_paths <- opt$bfilePaths
clump_p1 <- as.numeric(opt$p1clump)
clump_r2 <- as.numeric(opt$r2clump)
clump_kb <- as.numeric(opt$kbclump)

message(paste0(
  "Running for exposure: ",
  exposure_id,
  " and outcome: ",
  outcome_id
))

# import exposure --------------------------------------------------------
exposure_clumped <- readRDS(exposure)

exposure_initial <- readRDS(exposure_initial)

# import outcome ---------------------------------------------------------
outcome <- lapply(unique(exposure_initial$chr), \(x) {
  readRDS(paste0("chr", x, ".rds"))
})
# rbind if list
outcome <- do.call(rbind, outcome)

# format outcome
outcome <- format_data(
  dat = as.data.frame(outcome),
  type = "outcome",
  snp_col = opt$snpCol,
  beta_col = opt$betaCol,
  se_col = opt$seCol,
  eaf_col = opt$eafCol,
  effect_allele_col = opt$effectAlleleCol,
  other_allele_col = opt$otherAlleleCol,
  pval_col = opt$pvalCol
)

# identify exposure SNPs missing from outcome data
missing_snps <- filter(exposure_clumped, !SNP %in% outcome$SNP)$SNP
message(length(missing_snps), " exposure SNPs missing from outcome data.")
# if any are missing, find LD proxies
if (length(missing_snps) > 0) {
  message(paste0(
    "Identifying LD proxies for ",
    length(missing_snps),
    " SNPs. LD proxy threshold = ",
    ld_proxy_r2
  ))

  set_plink(path = Sys.which("plink"))
  proxies <- get_ld_proxies(
    rsid = missing_snps,
    bfile = bfile_paths,
    searchspace = outcome$SNP,
    tag_r2 = ld_proxy_r2
  )
  proxies <- proxies |>
    # present in exposure
    filter(SNP_B %in% exposure_initial$SNP) |>
    # pick LD proxy by highest absolute R for each SNP
    slice(which.max(abs(R)), .by = SNP_A)

  # remove any IV with proxy available
  iv <- exposure_clumped |>
    filter(SNP %in% proxies$SNP_A) |>
    bind_rows(exposure_initial |> filter(SNP %in% proxies$SNP_B))

  # drop if not in outcome
  iv <- iv |> filter(SNP %in% outcome$SNP)

  # reclump if more than one instrument
  if (nrow(iv) > 1) {
    iv <- clump_data(
      dat = iv,
      clump_kb = clump_kb,
      clump_r2 = clump_r2,
      clump_p1 = clump_p1,
      bfile = bfile_paths,
      plink_bin = Sys.which("plink")
    )
  }
} else {
  iv <- exposure_clumped
}

# subset outcome IVs
outcome <- outcome |> filter(SNP %in% iv$SNP)

# export -----------------------------------------------------------------
saveRDS(iv, "exposure_IV.rds")
saveRDS(outcome, "outcome_IV.rds")
