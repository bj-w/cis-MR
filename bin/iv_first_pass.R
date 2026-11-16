#!/usr/bin/env Rscript
library(data.table)
library(optparse)
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
    make_option("--kbclump")
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
exp <- exp[exp$chromosome == gsub("chr", "", gene_info$seqnames), ]
# within kb window
lower_window <- meta$tss - window_tss
upper_window <- meta$tss + window_tss
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
  snp_col = "rsid",
  beta_col = "beta",
  se_col = "standard_error",
  eaf_col = "effect_allele_frequency",
  effect_allele_col = "effect_allele",
  other_allele_col = "other_allele",
  pval_col = "p_value"
)

# LD clumping
exp_clumped <- clump_data(
  dat = exp,
  clump_kb = clump_kb,
  clump_r2 = clump_r2,
  clump_p1 = clump_p1,
  bfile = bfile_paths,
  plink_bin = Sys.which("plink")
)

saveRDS(exp_clumped, paste0(exposure_id, "iv.ld_clumped.rds"))
}
