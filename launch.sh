#! /bin/bash
nextflow run cisMR.nf \
    -resume \
    --outdir cisMR_output/ \
    -params-file params.yaml
