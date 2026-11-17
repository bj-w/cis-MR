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
    ld_reference_files = null
    pvalClump = null
    r2Clump = null
    kbClump = null
    ld_proxy_r2_threshold = null
    exposure_snp_column = null
    exposure_beta_column = null
    exposure_se_column = null
    exposure_pval_column = null
    exposure_eaf_column = null
    exposure_effect_allele_column = null
    exposure_other_allele_column = null
    outcome_snp_column = null
    outcome_beta_column = null
    outcome_se_column = null
    outcome_pval_column = null
    outcome_eaf_column = null
    outcome_effect_allele_column = null
    outcome_other_allele_column = null
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

    // define exposure Columns
    def exposureColumns = [snp: params.exposure_snp_column, beta: params.exposure_beta_column, se: params.exposure_se_column, pval: params.exposure_pval_column, eaf: params.exposure_eaf_column, effect_allele: params.exposure_effect_allele_column, other_allele: params.exposure_other_allele_column]

    // define outcome columns
    def outcomeColumns = [snp: params.outcome_snp_column, beta: params.outcome_beta_column, se: params.outcome_se_column, pval: params.outcome_pval_column, eaf: params.outcome_eaf_column, effect_allele: params.outcome_effect_allele_column, other_allele: params.outcome_other_allele_column]

    // define LD clumping parameters
    def ld_clump_params = [kb: params.kbClump, r2: params.r2Clump, pval: params.pvalClump]

    // ════════════════════════════════════════════════════════════════
    // STEP 2: Setup reference files
    // ════════════════════════════════════════════════════════════════

    // extract location of all protein coding genes in the GTF
    ch_gene_loci = GENE_LOCI(params.gtf)

    // separate outcome summary statistics by chromosome
    ch_outcome = SEPARATE_OUTCOME_CHR(outcome_samplesheet_ch)

    // Stage LD references
    def ld_prefix = file(params.ld_reference_files).name // "EUR"
    def ld_files = files("${params.ld_reference_files}.{bed,bim,fam}", checkIfExists: true)

    ch_ld_ref = channel.value([ld_prefix, ld_files])

    // ════════════════════════════════════════════════════════════════
    // STEP 3: Get exposure IVs
    // ════════════════════════════════════════════════════════════════

    // find initial exposure IVs. Also performs LD clumping
    ch_exposure = IV_FIRST_PASS(
        exposure_samplesheet_ch,
        ch_gene_loci,
        params.pvalThreshold,
        params.windowTSS,
        ch_ld_ref,
        ld_clump_params,
        exposureColumns,
    )

    // ════════════════════════════════════════════════════════════════
    // STEP 4: Exposure-outcome pairs
    // ════════════════════════════════════════════════════════════════

    // specify channel so we create combinations of exposure-outcome pairs
    ch_exposure_outcome_pairs = ch_exposure
        .combine(ch_outcome.outcome_files)
        .map { exposure_id, exposure_iv, exposure_iv_initial, outcome_id, outcome_file ->
            tuple(exposure_id, outcome_id, exposure_iv, exposure_iv_initial, outcome_file)
        }

    // Ensure exposure IVs are in outcome data
    ch_iv = FORMAT_IV(
        ch_exposure_outcome_pairs,
        params.ld_proxy_r2_threshold,
        ch_ld_ref,
        ld_clump_params,
        outcomeColumns,
    )

    // ════════════════════════════════════════════════════════════════
    // STEP 5: Run MR for each exposure-outcome pair
    // ════════════════════════════════════════════════════════════════
    MR(ch_iv)
}
