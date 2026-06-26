#!/usr/bin/env Rscript
source("/project/rv/scripts/activate.R")
library(data.table)
library(optparse)
# parse arguments
opt <- parse_args(OptionParser(
  option_list = list(
    make_option("--exposureFileDir"),
    make_option("--exposureFileName"),
    make_option("--geneSymbol"),
    make_option("--pvalThreshold"),
    make_option("--kbWindow")
  )
))
opt$exposureFileDir <- exposure_dir
opt$exposureFileName <- exposure_file
opt$geneSymbol <- gene_symbol
opt$pvalThreshold <- pval_threshold
opt$kbWindow <- kb_window

exp <- fread(paste0(
  exposure_dir, "/",
  exposure_file,
  ".harmonised.txt.gz"
))

# associated with exposure
exp <- exp[exp$p_value < pval_threshold, ]

# cis-pQTL
gene_loci <- readRDS("data/gene_loci.rds")
gene_loci <- gene_loci[gene_loci$gene_name == gene_symbol, ]
# identify SNPs within window of the gene
# same chromosome
exp <- exp[exp$chromosome == gsub("chr", "", gene_loci$seqnames), ]
# within kb window
exp <- exp[
  exp$base_pair_location >= gene_loci$start - kb_window &
    exp$base_pair_location <= gene_loci$end + kb_window,
]


# # remove NA rsid
# iv <- iv %>% drop_na(rsids)

# export prelim IVs
saveRDS(exp, paste0(exposure_file, ".iv.first_pass.rds"))
# export info needed for clumping (rsid, pval)
write.table(
  data.frame(SNP = exp$rsid, P = exp$p_value),
  file = paste0(exposure_file, ".iv.to_clump.txt"),
  row.names = FALSE,
  col.names = TRUE,
  quote = FALSE
)
