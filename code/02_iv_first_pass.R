library(data.table)
library(genetics.binaRies)
library(TwoSampleMR)
library(tidyverse)

exposure_file <- "4496_60_MMP12_MMP_12"
exposure_id <- "MMP12"
pval_threshold <- 5e-8

exposure_gwas <- fread(paste0(
  "raw_data/gwas_summary_stats/soma_pqtl/",
  exposure_file,
  ".txt.gz"
))

# associated with exposure
iv <- exposure_gwas %>% filter(Pval < pval_threshold)

# cis-pQTL
gene_loci <- read_parquet("mr/data/gene_loci.parquet")
gene_loci <- gene_loci %>% filter(gene_name == exposure_id)
# deCODE used +/- 1mb of the TSS
iv <- iv %>%
  filter(
    Chrom == gene_loci$chromosome,
    Pos <= gene_loci$tss + 1e+6 & Pos >= gene_loci$tss - 1e+6
  )

# export prelim IVs
write_parquet(iv, paste0("mr/data/", exposure_file, ".iv.first_pass.parquet"))
# export info needed for clumping (rsid, pval)
write.table(
  data.frame(SNP = iv$rsids, P = iv$Pval),
  file = paste0("mr/data/", exposure_file, "iv.to_clump.txt"),
  row.names = FALSE,
  col.names = TRUE,
  quote = FALSE
)
