process SEPARATE_OUTCOME_CHR {
    container 'whittlebj/rv-cis-mr:latest'
    memory '16GB'
    time '10min'
    tag "${outcome_id}"

    input:
        tuple val(outcome_id), path(outcome_file)

    output:
        tuple val(outcome_id), path('*.rds'), emit: outcome_files

    script:
    """
    separate_chr_outcome.R --outcomeGWAS ${outcome_file}
    """
}
