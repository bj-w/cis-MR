process IV_FIRST_PASS {
    container 'whittlebj/rv-cis-mr:latest'
    cpus 4
    memory '16GB'
    time '20min'
    tag "${exposure_id}"

    input:
        tuple val(exposure_id), val(gene_id), path(exposure_file)
        path gene_loci
        val pval
        val tss_kb
        tuple val(ld_prefix), path(ld_files)
        val clump_p1
        val clump_r2
        val clump_kb

    output:
        tuple val(exposure_id), path('iv.ld_clumped.rds'), path('iv.initial.rds'), emit: exposure_iv, optional: true

    script:
    """
    iv_first_pass.R \
        --exposureFilePath ${exposure_file} \
        --exposureFileID ${exposure_id} \
        --geneID ${gene_id} \
        --geneLoci ${gene_loci} \
        --pvalThreshold ${pval} \
        --windowTSS ${tss_kb} \
        --bfilePaths ${ld_prefix} \
        --p1clump ${clump_p1} \
        --r2clump ${clump_r2} \
        --kbclump ${clump_kb}
    """
}
