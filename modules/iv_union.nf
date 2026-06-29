process IV_UNION {
    container 'whittlebj/rv-cis-mr:latest'
    memory '16GB'
    time '20min'
    tag "${exposure_id}"

    input:
        tuple val(exposure_id), path(iv)
        path(outcome_rds)

    output:
        tuple val(exposure_id), path('*.exposure_IV.rds'), path("*.outcome_IV.rds")

    script:
    """
    iv_union.R \
        --clumpedIV ${iv} \
        --exposureID ${exposure_id}
    """
}
