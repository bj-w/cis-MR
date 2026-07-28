# *cis*MR

Workflow to run two-sample *cis* Mendelian Randomisation analyses.

## Requirements

**Nextflow** - I find using a Pixi/Conda/Mamba environment easiest.

``` bash
curl -fsSL https://pixi.sh/install.sh | sh
pixi config set default-channels '["conda-forge", "bioconda"]'
pixi global install nextflow
```

**Docker/Singularity/Apptainer** - all software is packaged in Docker containers to help with ease + reproducibility. If on HPC, the use of Apptainer can be specified in a Nextflow config file.

``` ymal
apptainer {
    // Enable Apptainer execution
    enabled = true
    // Auto-mount host paths (if your Apptainer installation supports it)
    autoMounts = true
}
```

## Set up

A GTF annotation is required to define positions of genes in the genome

``` bash
wget https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_50/gencode.v50.primary_assembly.basic.annotation.gtf.gz
```

A linkage disequilibirum population reference which can be downloaded as below

``` bash
wget http://fileserve.mrcieu.ac.uk/ld/1kg.v3.tgz
tar -xvzf 1kg.v3.tgz
```

Exposure and outcome summary statistics - these need to be harmonised following the [GWAS Catalog](https://www.ebi.ac.uk/gwas/) format outlined below.

|  |  |
|----|----|
| Column | Notes |
| chromosome | No "chr" |
| base_pair_location |  |
| effect_allele |  |
| other_allele |  |
| beta |  |
| standard_error |  |
| effect_allele_frequency |  |
| p_value |  |
| rsid | Required for LD clumping |
| N_cases | Not needed |
| N_controls | Not needed |
| hm_coordinate_conversion | Not needed |
| hm_code | Not needed |
| variant_id | chromsome_basePairLocation_otherAllele_effectAllele |

## Instructions

Workflow parameters

| Flag | Description | Example |
|------------------------|------------------------|------------------------|
| outdir | Output folder name to be created in the current directory | output |
| exposureSamplesheet | CSV file containing info about the exposure(s) | /path/to/exposure_samplesheet.csv |
| outcomeSamplesheet | CSV file containing info about the outcome(s) | /path/to/outcome_samplesheet.csv |
| gtf | GTF annotation - only tested with [GENCODE](https://www.gencodegenes.org/human/). | /path/to/gencode.v50.basic.annotation.gtf.gz |
| pvalThreshold | P-value threshold to define genetic associations with the exposure | 5e-8 |
| windowTSS | Window around the gene transcription start site (in kilobases) in which to identify <i>cis</i>-acting genetic variants | 1000000 |
| bedPopulationLD | Path to PLINK bed population LD file | path/to/EUR.bed |
| bimPopulationLD | Path to PLINK bimpopulation LD file | path/to/EUR.bim |
| famPopulationLD | Path to PLINK fam population LD file | path/to/EUR.fam |
| pvalClump | Clumping p-value threshold for index SNPs | 1 |
| r2Clump | Clumping r2 threshold | 0.001 |
| kbClump | Clumping window | 10000 |

These parameters can be passed in a `params.json` file, or when submitting the nextflow script like below

``` bash
nextflow run cisMR.nf \
    --outdir cisMR_output/ \
    --exposureSamplesheet $PWD/exposure_samplesheet.csv \
    --outcomeSamplesheet $PWD/outcome_samplesheet.csv \
    --gtf $PWD/raw_data/gencode.v50.basic.annotation.gtf.gz \
    --pvalThreshold 5e-8 \
    --windowTSS 1000000 \
    --bedPopulationLD $PWD/raw_data/1kg/EUR.bed \
    --bimPopulationLD $PWD/raw_data/1kg/EUR.bim \
    --famPopulationLD $PWD/raw_data/1kg/EUR.fam \
    --pvalClump 1 \
    --r2Clump 0.001 \
    --kbClump 10000
```

## Output

If successful, output should look similar to below with a different directory for each unique outcome data source. For each exposure, there should be harmonised IV dataframes (for downstream sensitivity and plotting) and the default MR results.

``` bash
.
|-- outcomeID_1
|   |-- harmonised_iv
|   |   `-- exposureID_1.IV_harmonised.csv
|   |   `-- exposureID_2.IV_harmonised.csv
|   `-- mr_results
|       `-- exposureID_1.mr_results.csv
|       `-- exposureID_2.mr_results.csv
`-- outcomeID_2
    |-- harmonised_iv
    |   `-- exposureID_1.IV_harmonised.csv
    |   `-- exposureID_2.IV_harmonised.csv
    `-- mr_results
        `-- exposureID_1.mr_results.csv
        `-- exposureID_2.mr_results.csv
```
