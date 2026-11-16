process FORMAT_IV {
    container 'whittlebj/rv-cis-mr:latest'
    memory '16GB'
    time '20min'
    tag "${exposure_id}_${outcome_id}"

    input:
     tuple val(exposure_id), val(outcome_id), path(clumped_iv_file), path(outcome_file)
     val proxy_r2
     path bfiles
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
        --exposureID ${exposure_id} \
        --outcomeID ${outcome_id}
       --ldProxyR2 ${proxy_r2} \
    --bfilePaths ${bfiles} \
    --p1clump ${1} \
    --r2clump ${clump_r2} \
    --kbclump ${clump_kb}
    """
}
