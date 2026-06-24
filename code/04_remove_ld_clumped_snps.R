exposure_file <- "4496_60_MMP12_MMP_12"
exposure_id <- "MMP12"
dat <- readRDS(paste0("data/", exposure_file, ".iv.first_pass.rds"))
res <- read.table(paste0("data/", exposure_file, ".clumped"), header = TRUE)
# from ieugwasr::ld_clump_local()
y <- subset(dat, !dat[["rsid"]] %in% res[["SNP"]])
if (nrow(y) > 0) {
  message(
    "Removing ",
    length(y[["rsid"]]),
    " of ",
    nrow(dat),
    " variants due to LD with other variants or absence from LD reference panel"
  )
}
ld_clumped_iv <- subset(dat, dat[["rsid"]] %in% res[["SNP"]])
saveRDS(ld_clumped_iv, paste0("data/", exposure_file, ".iv.ld_clumped.rds"))
