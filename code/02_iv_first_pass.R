library(data.table)
library(TwoSampleMR)
library(tidyverse)

exposure_file <- "4496_60_MMP12_MMP_12"
exposure_id <- "MMP12"
pval_threshold <- 5e-8

exposure_gwas <- fread(paste0(
  "raw_data/soma_pqtl/",
  exposure_file,
  ".txt.gz"
))

# associated with exposure
iv <- exposure_gwas %>% filter(Pval < pval_threshold)

# cis-pQTL
gene_loci <- readRDS("data/gene_loci.rds")
gene_loci <- gene_loci %>% filter(gene_name == exposure_id)
# deCODE used +/- 1mb of the TSS
iv <- iv %>%
  filter(
    Chrom == gene_loci$chromosome,
    Pos <= gene_loci$tss + 1e+6 & Pos >= gene_loci$tss - 1e+6
  )

# remove NA rsid
iv <- iv %>% drop_na(rsids)

# export prelim IVs
saveRDS(iv, paste0("data/", exposure_file, ".iv.first_pass.rds"))
# export info needed for clumping (rsid, pval)
write.table(
  data.frame(SNP = iv$rsids, P = iv$Pval),
  file = paste0("data/", exposure_file, ".iv.to_clump.txt"),
  row.names = FALSE,
  col.names = TRUE,
  quote = FALSE
)
