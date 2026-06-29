process MR {
    container 'mrcieu/twosamplemr:0.7.9'
    memory '8GB'
    time '20min'
    tag "${exposure_id}"
    publishDir "${params.outDir}/", mode: "copy"

    input:
        tuple val(exposure_id), path(exposure), path(outcome)

    output:
        path("*.IV_harmonised.csv"), emit: harmonised_IV
        path("*.mr_results.csv"), emit: mr

    script:
    """
    mr.R ${exposure_id} ${exposure} ${outcome}
    """
}
