#!/usr/bin/env Rscript
library(data.table)
library(optparse)
library(tidyverse)
library(TwoSampleMR)


# parse arguments --------------------------------------------------------
opt <- parse_args(OptionParser(
  option_list = list(
    make_option("--exposureFilePath"),
    make_option("--exposureFileID"),
    make_option("--geneID"),
    make_option("--geneLoci"),
    make_option("--pvalThreshold"),
    make_option("--windowTSS"),
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
exposure_path <- opt$exposureFilePath
exposure_id <- opt$exposureFileID
gene_id <- opt$geneID
gene_loci_path <- opt$geneLoci
pval_threshold <- as.numeric(opt$pvalThreshold)
window_tss <- as.numeric(opt$windowTSS)
bfile_paths <- opt$bfilePaths
clump_p1 <- as.numeric(opt$p1clump)
clump_r2 <- as.numeric(opt$r2clump)
clump_kb <- as.numeric(opt$kbclump)


# import exposure
exp <- fread(paste0(exposure_path))

# associated with exposure below pvalue threshold
exp <- exp[exp$p_value < pval_threshold, ]

# cis-pQTL
gene_info <- readRDS(gene_loci_path)
gene_info <- gene_info[gene_info$gene_id == gene_id, ]
# identify SNPs within window of the gene transcription start site
# same chromosome
chromosome <- gsub("chr", "", gene_info$seqnames)
exp <- exp[exp$chromosome == chromosome, ]
# within kb window
lower_window <- gene_info$tss - window_tss
upper_window <- gene_info$tss + window_tss
exp <- exp[
  exp$base_pair_location >= lower_window &
    exp$base_pair_location <= upper_window,
]


if (nrow(exp) == 0) {
  message("No cis-pQTLs.")
} else {
  # format data
  exp <- format_data(
    dat = as.data.frame(exp),
    type = "exposure",
    snp_col = opt$snpCol,
    beta_col = opt$betaCol,
    se_col = opt$seCol,
    eaf_col = opt$eafCol,
    effect_allele_col = opt$effectAlleleCol,
    other_allele_col = opt$otherAlleleCol,
    pval_col = opt$pvalCol
  )
  exp <- exp |> mutate(chr = chromosome)
  saveRDS(exp, "iv.initial.rds")

  # run LD clumping if SNPs are found in LD reference. Otherwise workflow crashes.
  bim_rsid <- fread(paste0(bfile_paths, ".bim"))$V2
  n_snps_in_lds_ref <- sum(exp$SNP %in% bim_rsid)
  if (n_snps_in_lds_ref == 0) {
    message(
      "No rsid overlap between potential IVs and the LD reference. Sex chromosome?"
    )
  } else {
    # LD clumping
    exp_clumped <- clump_data(
      dat = exp,
      clump_kb = clump_kb,
      clump_r2 = clump_r2,
      clump_p1 = clump_p1,
      bfile = bfile_paths,
      plink_bin = Sys.which("plink")
    )
    saveRDS(exp_clumped, "iv.ld_clumped.rds")
  }
}
