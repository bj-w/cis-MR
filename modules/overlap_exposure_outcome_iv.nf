process OVERLAP_EXPOSURE_OUTCOME_IV {
    container 'whittlebj/rv-cis-mr:latest'
    memory '16GB'
    time '20min'
    tag "${exposure_id}_${outcome_id}"

    input:
     tuple val(exposure_id), val(outcome_id), path(clumped_iv_file), path(outcome_file)

    output:
        tuple val(exposure_id), val(outcome_id), path('exposure_IV.rds'), path("outcome_IV.rds"), optional: true

    script:
    """
    if [ ! -s ${clumped_iv_file} ]; then
        echo "No IVs for ${exposure_id} × ${outcome_id}"
        exit 0
    fi

    overlap_exposure_outcome_iv.R \
        --clumpedIV ${clumped_iv_file} \
        --exposureID ${exposure_id} \
        --outcomeID ${outcome_id}
    """
}
