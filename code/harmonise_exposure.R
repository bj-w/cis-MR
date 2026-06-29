source("/project/rv/scripts/activate.R")
library(data.table)
library(R.utils) # to read gz files

outcome_file_path <- "raw_data/soma_pqtl/4496_60_MMP12_MMP_12.txt.gz"
gwas <- fread(outcome_file_path)
harmonised <- data.frame(chromosome = gsub("chr", "", gwas$Chrom))
harmonised$base_pair_location <- gwas$Pos
harmonised$effect_allele <- gwas$effectAllele
harmonised$other_allele <- gwas$otherAllele
harmonised$beta <- gwas$Beta
harmonised$standard_error <- gwas$SE
harmonised$effect_allele_frequency <- gwas$ImpMAF
harmonised$p_value <- gwas$Pval
harmonised$rsid <- gwas$rsids
harmonised$N_cases <- NA
harmonised$N_controls <- NA
harmonised$hm_coordinate_conversion <- NA
harmonised$hm_code <- NA
harmonised$variant_id <- paste(
  harmonised$chromosome,
  harmonised$base_pair_location,
  harmonised$other_allele,
  harmonised$effect_allele,
  sep = "_"
)

fwrite(
  harmonised,
  file = "data/4496_60_MMP12_MMP_12.harmonised.txt.gz",
  sep = "\t"
)
