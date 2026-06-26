// -------\\
// cis-MR \\
// -------\\

// Parameters
params.outdir = null
params.samplesheet = null
params.gtf = null
params.outcome = null
params.exposureDir = null
params.pvalThreshold = null
params.kbWindow = null


// Modules
include { GENE_LOCI } from './modules/gene_loci'
include { SEPARATE_OUTCOME_CHR } from './modules/separate_outcome_chr'
include { IV_FIRST_PASS } from './modules/iv_first_pass'

// Workflow
workflow {
    // emits tuples of [exposure_file, gene_symbol]
    ch_samplesheet = channel
        .fromPath(params.samplesheet)
        .flatMap { path -> path.splitCsv(header: true) }
        .map { row -> [ row.exposure_file, row.gene_symbol ] }

    ch_gene_loci = GENE_LOCI(params.gtf)
    ch_outcome = SEPARATE_OUTCOME_CHR(params.outcome)

    iv_first_pass_ch = IV_FIRST_PASS(params.exposureDir,
    ch_samplesheet.exposure_file,
    ch_samplesheet.gene_symbol,
    params.pvalThreshold,
    params.kbWindow
    )
}
