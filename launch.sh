#! /bin/bash
nextflow run cisMR.nf \
    -resume \
    --outdir cisMR_output/ \
    --exposureSamplesheet $PWD/../exposure_samplesheet.csv \
    --outcomeSamplesheet $PWD/../outcome_samplesheet.csv \
    --gtf $PWD/../refs/gencode.v50.basic.annotation.gtf.gz \
    --pvalThreshold 5e-8 \
    --windowTSS 100000 \
    --LDreferenceFiles $PWD/../refs/EUR \
    --pvalClump 1 \
    --r2Clump 0.001 \
    --kbClump 10000 \
    --LDproxyR2 0.8
