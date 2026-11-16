// -------\\
// cis-MR \\
// -------\\

// Parameters
params {
    outdir = null
    exposureSamplesheet = null
    outcomeSamplesheet = null
    gtf = null
    pvalThreshold = null
    windowTSS = null
    LDreferenceFiles = null
    pvalClump = null
    r2Clump = null
    kbClump = null
    LDproxyR2 = null
}


// Modules
include { GENE_LOCI } from './modules/gene_loci'
include { SEPARATE_OUTCOME_CHR } from './modules/separate_outcome_chr'
include { IV_FIRST_PASS } from './modules/iv_first_pass'
include { FORMAT_IV } from './modules/format_iv'
include { MR } from './modules/mr'

// Workflow
workflow {
    // ════════════════════════════════════════════════════════════════
    // STEP 1: Load and validate input samplesheets
    // ════════════════════════════════════════════════════════════════

    // exposure samplesheet
    exposure_samplesheet_ch = channel.fromPath(params.exposureSamplesheet)
        .splitCsv(header: true)
        .map { row -> tuple(row.exposure_id, row.gene_id, row.exposure_file) }

    // outcome samplesheet
    outcome_samplesheet_ch = channel.fromPath(params.outcomeSamplesheet)
        .splitCsv(header: true)
        .map { row -> tuple(row.outcome_id, row.outcome_file) }

    // ════════════════════════════════════════════════════════════════
    // STEP 2: Setup reference files
    // ════════════════════════════════════════════════════════════════

    // extract location of all protein coding genes in the GTF
    ch_gene_loci = GENE_LOCI(params.gtf)

    // separate outcome summary statistics by chromosome
    ch_outcome = SEPARATE_OUTCOME_CHR(outcome_samplesheet_ch)

    // ════════════════════════════════════════════════════════════════
    // STEP 3: Get exposure IVs
    // ════════════════════════════════════════════════════════════════

    // find initial exposure IVs. Also performs LD clumping
    ch_exposure = IV_FIRST_PASS(
        exposure_samplesheet_ch,
        ch_gene_loci,
        params.pvalThreshold,
        params.windowTSS,
        params.LDreferenceFiles,
        params.pvalClump,
        params.r2Clump,
        params.kbClump,
    )

    // ════════════════════════════════════════════════════════════════
    // STEP 4: Exposure-outcome pairs
    // ════════════════════════════════════════════════════════════════

    // specify channel so we create combinations of exposure-outcome pairs
    ch_exposure_outcome_pairs = ch_exposure
        .combine(ch_outcome.outcome_files)
        .map { exposure_id, iv_clumped, outcome_id, outcome_file ->
            tuple(exposure_id, outcome_id, iv_clumped, outcome_file)
        }

    // Ensure exposure IVs are in outcome data
    ch_iv = FORMAT_IV(
        ch_exposure_outcome_pairs,
        params.LDproxyR2,
        params.LDreferenceFiles,
        params.pvalClump,
        params.r2Clump,
        params.kbClump,
    )

    // ════════════════════════════════════════════════════════════════
    // STEP 5: Run MR for each exposure-outcome pair
    // ════════════════════════════════════════════════════════════════
    MR(ch_iv)
}
