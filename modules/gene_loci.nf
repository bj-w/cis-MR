process GENE_LOCI {
    container 'docker://quay.io/biocontainers/bioconductor-rtracklayer:1.70.1--r45h01b2380_0'
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
