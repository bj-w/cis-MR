#! /bin/bash
nextflow run cisMR.nf \
    -resume \
    --outdir cisMR_output/ \
    --exposureSamplesheet $PWD/exposure_samplesheet.csv \
    --outcomeSamplesheet $PWD/outcome_samplesheet.csv \
    --gtf $PWD/raw_data/gencode.v50.basic.annotation.gtf.gz \
    --pvalThreshold 5e-8 \
    --kbWindow 100000 \
    --bedPopulationLD $PWD/raw_data/1kg/EUR.bed \
    --bimPopulationLD $PWD/raw_data/1kg/EUR.bim \
    --famPopulationLD $PWD/raw_data/1kg/EUR.fam \
    --pvalClump 1 \
    --r2Clump 0.001 \
    --kbClump 10000
