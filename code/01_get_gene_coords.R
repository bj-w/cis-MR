library(rtracklayer)
library(tidyverse)
gencode_path <- "raw_data/gencode.v50.basic.annotation.gtf.gz"

gtf <- import(paste0(gencode_path))
gtf <- as.data.frame(gtf)
gene_loci <- gtf %>%
    filter(type == "gene", gene_type == "protein_coding") %>%
    select(gene_name, chromosome = seqnames, start, end, strand, gene_id)
# add TSS and TES
gene_loci <- gene_loci %>%
    mutate(
        tss = if_else(strand == "+", start, end),
        tes = if_else(strand == "+", end, start)
    )
# remove trailing version number from ensembl gene IDs
gene_loci <- gene_loci %>% mutate(gene_id = str_remove(gene_id, "\\..*"))
saveRDS(gene_loci, "data/gene_loci.rds")
