process IV_FIRST_PASS {
    container 'whittlebj/rv-cis-mr:latest'
    cpus 4
    memory '16GB'
    time '20min'

    input:
        path exposure_dir
        val exposure_file
        val gene_symbol
        val pval
        val kb

    output:
        path '*.iv.first_pass.rds', emit: iv_df
        path '*.iv.to_clump.txt', emit: iv_toClump

    script:
    """
    iv_first_pass.R \
        --exposureFileDir ${exposure_dir} \
        --exposureFileName ${exposure_file} \
        --geneSymbol ${gene_symbol} \
        --pvalThreshold ${pval} \
        --kbWindow ${kb}
    """
}
