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
    make_option("--geneLoci"),
    make_option("--pvalThreshold"),
    make_option("--kbWindow")
  )
))
exposure_dir <- opt$exposureFileDir
exposure_id <- opt$exposureFileName
gene_symbol <- opt$geneSymbol
gene_loci_path <- opt$geneLoci
pval_threshold <- opt$pvalThreshold
kb_window <- as.numeric(opt$kbWindow)

exp <- fread(paste0(
  exposure_dir, "/",
  exposure_id,
  ".harmonised.txt.gz"
))

# associated with exposure
exp <- exp[exp$p_value < pval_threshold, ]

# cis-pQTL
gene_info <- readRDS(gene_loci_path)
head(gene_info)
dim(gene_info)
print(gene_symbol)
gene_info <- gene_info[gene_info$gene_name == gene_symbol, ]
# identify SNPs within window of the gene
# same chromosome
exp <- exp[exp$chromosome == gsub("chr", "", gene_info$seqnames), ]
# within kb window
exp <- exp[
  exp$base_pair_location >= gene_info$start - kb_window &
    exp$base_pair_location <= gene_info$end + kb_window,
]


# # remove NA rsid
# iv <- iv %>% drop_na(rsids)

# export prelim IVs
saveRDS(exp, paste0(exposure_id, ".iv.first_pass.rds"))
# export info needed for clumping (rsid, pval)
write.table(
  data.frame(SNP = exp$rsid, P = exp$p_value),
  file = paste0(exposure_id, ".iv.to_clump.txt"),
  row.names = FALSE,
  col.names = TRUE,
  quote = FALSE
)
