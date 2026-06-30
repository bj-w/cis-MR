#!/usr/bin/env Rscript
library(optparse)
# parse arguments
opt <- parse_args(OptionParser(
  option_list = list(
    make_option("--exposure"),
    make_option("--firstPass"),
    make_option("--clumped")
  )
))
message("Check clumped exists")
file.exists(opt$clumped)
dat <- readRDS(opt$firstPass)
res <- read.table(opt$clumped, header = TRUE)
exposure_id <- opt$exposure
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
saveRDS(ld_clumped_iv, paste0(exposure_id, ".iv.ld_clumped.rds"))
