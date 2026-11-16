process FORMAT_IV {
    container 'whittlebj/rv-cis-mr:latest'
    memory '16GB'
    time '20min'
    tag "${exposure_id}_${outcome_id}"

    input:
    tuple val(exposure_id), val(outcome_id), path(clumped_iv_file), path(iv_initial), path(outcome_files)
    val ld_proxy_r2
    tuple val(ld_prefix), path(ld_files)
    val clump_p1
    val clump_r2
    val clump_kb

    output:
    tuple val(exposure_id), val(outcome_id), path('exposure_IV.rds'), path("outcome_IV.rds"), optional: true

    script:
    """
    if [ ! -s ${clumped_iv_file} ]; then
        echo "No IVs for ${exposure_id} × ${outcome_id}"
        exit 0
    fi

    format_IV.R \
        --clumpedIV ${clumped_iv_file} \
        --initialIV ${iv_initial} \
        --exposureID ${exposure_id} \
        --outcomeID ${outcome_id} \
        --ldProxyR2 ${ld_proxy_r2} \
        --bfilePaths ${ld_prefix} \
        --p1clump ${1} \
        --r2clump ${clump_r2} \
        --kbclump ${clump_kb}
    """
}
