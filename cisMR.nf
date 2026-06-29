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
params.bedPopulationLD = null
params.bimPopulationLD = null
params.famPopulationLD = null
params.pvalClump = null
params.r2Clump = null
params.kbClump = null

// Modules
include { GENE_LOCI } from './modules/gene_loci'
include { SEPARATE_OUTCOME_CHR } from './modules/separate_outcome_chr'
include { IV_FIRST_PASS } from './modules/iv_first_pass'
include { LD_CLUMP } from './modules/ld_clump'
include { EXCLUDE_CLUMPED_IV } from './modules/exclude_clumped_iv'
include { IV_UNION } from './modules/iv_union'
include { MR } from './modules/mr'

// Workflow
workflow {
    // emits tuples of [exposure_id, gene_symbol]
    ch_samplesheet = channel
        .fromPath(params.samplesheet)
        .splitCsv(header: true)
        .map { row -> tuple(row.exposure_id, row.gene_symbol) }

    ch_gene_loci = GENE_LOCI(params.gtf)
    ch_outcome = SEPARATE_OUTCOME_CHR(params.outcome)

    ch_iv_first_pass = IV_FIRST_PASS(
        params.exposureDir,
        ch_samplesheet,
        ch_gene_loci,
        params.pvalThreshold,
        params.kbWindow
    )

    ch_ld_clump = LD_CLUMP(
        ch_iv_first_pass.iv_toClump,
        params.bedPopulationLD,
        params.bimPopulationLD,
        params.famPopulationLD,
        params.pvalClump,
        params.r2Clump,
        params.kbClump
    )

    // Join the three channels on exposure_id (first element of tuple)
    ch_combined = ch_iv_first_pass.iv_df
        .join(ch_ld_clump.clumped_iv)
        .map { exposure_id, iv_rds, clumped_file ->
            tuple(exposure_id, iv_rds, clumped_file)
        }

    ch_clumped_iv = EXCLUDE_CLUMPED_IV(ch_combined)

    // Ensure exposure IVs are in outcome data
   ch_iv_union = IV_UNION(ch_clumped_iv, ch_outcome.outcome_files)

    // Run MR
    MR(ch_iv_union)
}
