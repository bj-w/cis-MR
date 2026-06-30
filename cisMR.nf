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
    kbWindow = null
    bedPopulationLD = null
    bimPopulationLD = null
    famPopulationLD = null
    pvalClump = null
    r2Clump = null
    kbClump = null
}


// Modules
include { GENE_LOCI } from './modules/gene_loci'
include { SEPARATE_OUTCOME_CHR } from './modules/separate_outcome_chr'
include { IV_FIRST_PASS } from './modules/iv_first_pass'
include { LD_CLUMP } from './modules/ld_clump'
include { EXCLUDE_CLUMPED_IV } from './modules/exclude_clumped_iv'
include { OVERLAP_EXPOSURE_OUTCOME_IV } from './modules/overlap_exposure_outcome_iv'
include { MR } from './modules/mr'

// Workflow
workflow {
    main:

    // ════════════════════════════════════════════════════════════════
    // STEP 1: Load and validate input samplesheets
    // ════════════════════════════════════════════════════════════════

    // exposure samplesheet
    exposure_samplesheet_ch = channel
        .fromPath(params.exposureSamplesheet)
        .splitCsv(header: true)
        .map { row -> tuple(row.exposure_id, row.gene_symbol, row.exposure_file) }

    // outcome samplesheet
    outcome_samplesheet_ch = channel
        .fromPath(params.outcomeSamplesheet)
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

    // find initial exposure IVs
    ch_iv_first_pass = IV_FIRST_PASS(
        exposure_samplesheet_ch,
        ch_gene_loci,
        params.pvalThreshold,
        params.kbWindow
    )

    // perform LD clumping on the initial exposure IVs to find near-independent variants
    ch_ld_clump = LD_CLUMP(
        ch_iv_first_pass.iv_toClump,
        params.bedPopulationLD,
        params.bimPopulationLD,
        params.famPopulationLD,
        params.pvalClump,
        params.r2Clump,
        params.kbClump
    )

    // Create channel based on the initial IVs and the clumped IVs
    ch_combined = ch_iv_first_pass.iv_df
        .join(ch_ld_clump.clumped_iv)
        .map { exposure_id, iv_rds, clumped_file ->
            tuple(exposure_id, iv_rds, clumped_file)
        }
    // now exclude clumped IVs
    ch_clumped_iv = EXCLUDE_CLUMPED_IV(ch_combined)

    // ════════════════════════════════════════════════════════════════
    // STEP 4: Exposure-outcome pairs
    // ════════════════════════════════════════════════════════════════

    // specify channel so we create combinations of exposure-outcome pairs
    ch_exposure_outcome_pairs = ch_clumped_iv
        .combine(ch_outcome.outcome_files)
        .map { exposure_id, clumped_iv_file, outcome_id, outcome_file ->
            tuple(exposure_id, outcome_id, clumped_iv_file, outcome_file)
        }

    // Ensure exposure IVs are in outcome data
    ch_iv_union = OVERLAP_EXPOSURE_OUTCOME_IV(ch_exposure_outcome_pairs)

    // ════════════════════════════════════════════════════════════════
    // STEP 5: Run MR for each exposure-outcome pair
    // ════════════════════════════════════════════════════════════════
    mr_output = MR(ch_iv_union)
}
