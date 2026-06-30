process IV_FIRST_PASS {
    container 'whittlebj/rv-cis-mr:latest'
    cpus 4
    memory '16GB'
    time '20min'
    tag "${exposure_id}"

    input:
        tuple val(exposure_id), val(gene_symbol), path(exposure_file)
        path gene_loci
        val pval
        val kb

    output:
        tuple val(exposure_id), path('iv.first_pass.rds'), emit: iv_df
        tuple val(exposure_id), path('iv.to_clump.txt'), emit: iv_toClump

    script:
    """
    iv_first_pass.R \
        --exposureFilePath ${exposure_file} \
        --exposureFileID ${exposure_id} \
        --geneSymbol ${gene_symbol} \
        --geneLoci ${gene_loci} \
        --pvalThreshold ${pval} \
        --kbWindow ${kb}
    """
}
