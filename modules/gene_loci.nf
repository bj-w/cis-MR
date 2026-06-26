process GENE_LOCI {
    container 'whittlebj/rv-cis-mr:latest'
    cpus 4
    memory '16GB'
    time '20min'

    input:
        path gtf

    output:
        path 'gene_loci.rds', emit: gene_loci

    script:
    """
    gene_loci.R ${gtf}
    """
}
