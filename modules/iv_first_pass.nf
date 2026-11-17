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
    val ld_clump_params
    val exposureColumns

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
        --p1clump ${ld_clump_params.pval} \
        --r2clump ${ld_clump_params.r2} \
        --kbclump ${ld_clump_params.kb} \
        --snpCol ${exposureColumns.snp} \
        --betaCol ${exposureColumns.beta} \
        --seCol ${exposureColumns.se} \
        --pvalCol ${exposureColumns.pval} \
        --eafCol ${exposureColumns.eaf} \
        --effectAlleleCol ${exposureColumns.effect_allele} \
        --otherAlleleCol ${exposureColumns.other_allele}
    """
}
