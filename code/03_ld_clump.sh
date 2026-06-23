#! /bin/bash
plink \
    --bfile raw_data/1kg/EUR \
    --clump data/4496_60_MMP12_MMP_12.iv.to_clump.txt \
    --clump-p1 1 \
    --clump-r2 0.001 \
    --clump-kb 10000 --out data/4496_60_MMP12_MMP_12
