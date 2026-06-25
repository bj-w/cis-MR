// -------\\
// cis-MR \\
// -------\\

// Parameters
params.outdir = null
params.gtf = null

// Modules
include { GENE_LOCI } from './modules/gene_loci'
// Workflow
workflow {
    gene_loci_ch = GENE_LOCI(params.gtf)
}
