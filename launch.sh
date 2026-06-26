#! /bin/bash
nextflow run cisMR.nf \
    -resume \
    --samplesheet $PWD/samplesheet.csv \
    --gtf $PWD/raw_data/gencode.v50.basic.annotation.gtf.gz \
    --outcome $PWD/data/summary_stats_finngen_R13_M13_GIANTCELL.harmonised.gz \
    --exposureDir $PWD/data/ \
    --pvalThreshold 5e-8 \
    --kbWindow 100000
