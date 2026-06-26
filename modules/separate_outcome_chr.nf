process SEPARATE_OUTCOME_CHR {
    container 'whittlebj/rv-cis-mr:latest'
    memory '16GB'
    time '10min'

    input:
        path outcome

    output:
    path '*.rds', emit: outcome_files

    script:
    """
    separate_chr_outcome.R --outcomeGWAS ${outcome}
    """
}
