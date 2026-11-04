process MR {
    container 'mrcieu/twosamplemr:0.7.9'
    cpus 4
    memory '16GB'
    time '30min'
    tag "${exposure_id}_${outcome_id}"

    publishDir { "${params.outdir}/${outcome_id}/mr_results" }, mode: 'copy', pattern: '*.mr_results.rds'
    publishDir { "${params.outdir}/${outcome_id}/harmonised_iv" }, mode: 'copy', pattern: '*.IV_harmonised.rds'

    input:
        tuple val(exposure_id), val(outcome_id), path(exposure_iv), path(outcome_iv)

    output:
        tuple val(exposure_id), val(outcome_id), path('*mr_results.rds'), path('*IV_harmonised.rds'), optional: true

    script:
    """
    if [ ! -s ${exposure_iv} ]; then
        echo "No IVs for MR analysis: ${exposure_id} × ${outcome_id}"
        exit 0
    fi

    mr.R \
        ${exposure_id} \
        ${exposure_iv} \
        ${outcome_id} \
        ${outcome_iv}
    """
}
