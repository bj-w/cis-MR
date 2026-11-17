# *cis*MR

Workflow to run summary *cis* Mendelian Randomisation analyses.

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


## Instructions

Workflow parameters can be entered using a yaml with the `-params-file` flag.
```yaml
exposureSamplesheet: "/path/to/exposure_samplesheet.csv"
outcomeSamplesheet: "/path/to/outcome_samplesheet.csv"
gtf: "/path/to/gencode.v50.basic.annotation.gtf.gz"
pvalThreshold: 5e-8
windowTSS: 1000000
ld_reference_files:  "/path/to/EUR"
pvalClump: 1
r2Clump: 0.001
kbClump: 10000
ld_proxy_r2_threshold: 0.8
exposure_snp_column: "rsid"
exposure_beta_column: "beta"
exposure_se_column: "standard_error"
exposure_pval_column: "p_value"
exposure_eaf_column: "effect_allele_frequency"
exposure_effect_allele_column: "effect_allele"
exposure_other_allele_column: "other_allele"
outcome_snp_column: "hm_rsid"
outcome_beta_column: "hm_beta"
outcome_se_column: "standard_error"
outcome_pval_column: "p_value"
outcome_eaf_column: "hm_effect_allele_frequency"
outcome_effect_allele_column: "hm_effect_allele"
outcome_other_allele_column: "hm_other_allele"
```



``` bash
nextflow run cisMR.nf \
    --outdir cisMR_output/ \
    -params-file params.yaml
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
