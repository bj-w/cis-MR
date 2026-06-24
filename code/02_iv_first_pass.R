library(data.table)

exposure_file <- "4496_60_MMP12_MMP_12"
exposure_id <- "MMP12"
pval_threshold <- 5e-8
kb_window <- 100000

exp <- fread(paste0(
  "data/",
  exposure_file,
  ".harmonised.txt.gz"
))
str(exp)
# associated with exposure
exp <- exp[exp$p_value < pval_threshold, ]

# cis-pQTL
gene_loci <- readRDS("data/gene_loci.rds")
gene_loci <- gene_loci[gene_loci$gene_name == exposure_id, ]
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
saveRDS(exp, paste0("data/", exposure_file, ".iv.first_pass.rds"))
# export info needed for clumping (rsid, pval)
write.table(
  data.frame(SNP = exp$rsid, P = exp$p_value),
  file = paste0("data/", exposure_file, ".iv.to_clump.txt"),
  row.names = FALSE,
  col.names = TRUE,
  quote = FALSE
)
