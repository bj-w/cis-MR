process EXCLUDE_CLUMPED_IV {
    container 'whittlebj/rv-cis-mr:latest'
    cpus 4
    memory '16GB'
    time '20min'

    input:
        tuple val(exposure_id), path(first_pass_rds), path(clumped_file)

    output:
        tuple val(exposure_id), path('*.iv.ld_clumped.rds'), emit: ld_clumped_iv

    script:
    """
    exclude_clumped_iv.R \
        --exposure ${exposure_id} \
        --firstPass ${first_pass_rds} \
        --clumped ${clumped_file}
    """
}
