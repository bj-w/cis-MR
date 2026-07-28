#!/usr/bin/env Rscript
library(data.table)
library(optparse)
# parse arguments
opt <- parse_args(OptionParser(
  option_list = list(
    make_option("--exposureFilePath"),
    make_option("--exposureFileID"),
    make_option("--geneSymbol"),
    make_option("--geneLoci"),
    make_option("--pvalThreshold"),
    make_option("--windowTSS")
  )
))
exposure_path <- opt$exposureFilePath
exposure_id <- opt$exposureFileID
gene_symbol <- opt$geneSymbol
gene_loci_path <- opt$geneLoci
pval_threshold <- opt$pvalThreshold
window_tss <- as.numeric(opt$windowTSS)

exp <- fread(paste0(exposure_path))

# associated with exposure
exp <- exp[exp$p_value < pval_threshold, ]

# cis-pQTL
gene_info <- readRDS(gene_loci_path)
head(gene_info)
dim(gene_info)
print(gene_symbol)
gene_info <- gene_info[gene_info$gene_name == gene_symbol, ]
# identify SNPs within window of the gene transcription start site
# same chromosome
exp <- exp[exp$chromosome == gsub("chr", "", gene_info$seqnames), ]
# within kb window
exp <- exp[
  exp$base_pair_location >= gene_info$tss - window_tss &
    exp$base_pair_location <= gene_info$tss + window_tss,
]

if (nrow(exp) == 0) {
  message("No first-pass IVs detected.")
} else {
  # export prelim IVs
  saveRDS(exp, paste0("iv.first_pass.rds"))
  # export info needed for clumping (rsid, pval)
  write.table(
    data.frame(SNP = exp$rsid, P = exp$p_value),
    file = paste0("iv.to_clump.txt"),
    row.names = FALSE,
    col.names = TRUE,
    quote = FALSE
  )
}
