#!/usr/bin/env Rscript
library(rtracklayer)
args <- commandArgs(trailingOnly = TRUE)
gencode_path <- args[1]
print(gencode_path)
file.exists(gencode_path)

gtf <- import(paste0(gencode_path))
gtf <- as.data.frame(gtf)

# filter for protein coding genes
gtf <- gtf[gtf$type == "gene" & gtf$gene_type == "protein_coding", ]
gene_loci <- gtf[, c(
  "seqnames",
  "start",
  "end",
  "strand",
  "gene_id",
  "gene_name"
)]
# add TSS and TES
gene_loci$tss <- ifelse(gene_loci$strand == "+", gene_loci$start, gene_loci$end)
gene_loci$tes <- ifelse(gene_loci$strand == "+", gene_loci$end, gene_loci$start)
# remove trailing version number from ensembl gene IDs
gene_loci$gene_id <- gsub("\\..*", "", gene_loci$gene_id)
saveRDS(gene_loci, "gene_loci.rds")
