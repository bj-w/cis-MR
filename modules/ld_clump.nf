process LD_CLUMP {
    container 'quay.io/biocontainers/plink:1.90b7.7--h18e278d_1'
    memory '16GB'
    time '20min'
    tag "${exposure_id}"

    input:
        tuple val(exposure_id), path(snps_to_clump)
        path(bed)
        path(bim)
        path(fam)
        val(p1)
        val(r2)
        val(kb)

    output:
        tuple val(exposure_id), path('*.clumped'), emit: clumped_iv

    script:
    """
    plink \
    --bed ${bed} \
    --bim ${bim} \
    --fam ${fam} \
    --clump ${snps_to_clump} \
    --clump-p1 ${p1} \
    --clump-r2 ${r2} \
    --clump-kb ${kb} \
    --out ${exposure_id}
    """
}
