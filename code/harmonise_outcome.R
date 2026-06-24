library(data.table)
library(R.utils) # to read gz files

gwas <- fread(
  "raw_data/gca_gwas/summary_stats_finngen_R13_M13_GIANTCELL.gz"
)

harmonised <- data.frame(chromosome = gwas$`#chrom`)

harmonised$base_pair_location <- gwas$pos
harmonised$effect_allele <- gwas$alt
harmonised$other_allele <- gwas$ref
harmonised$beta <- gwas$beta
harmonised$standard_error <- gwas$sebeta
harmonised$effect_allele_frequency <- gwas$af_alt
harmonised$p_value <- gwas$pval
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
  file = "data/summary_stats_finngen_R13_M13_GIANTCELL.harmonised.gz",
  sep = "\t"
)
