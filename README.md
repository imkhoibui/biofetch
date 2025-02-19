# Biofetch

Biofetch automatically download the fastq files from your samplesheet csv, as long as they have valid accession ID

Available sources for retrieval: [ENA](https://www.ebi.ac.uk/ena/browser/home), [SRA](https://www.ncbi.nlm.nih.gov/sra)

# To test the module:

```
nextflow run main.nf -resume | tee headnode.log
```

You can modify the samplesheet in `data/` to test the module.

# Future improvements:

1/single-end & paired-end sanity check

2/curl options
