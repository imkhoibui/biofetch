# Biofetch

Biofetch automatically download the fastq files from your samplesheet csv, as long as they have valid accession ID

Available sources for retrieval: 

- [ENA](https://www.ebi.ac.uk/ena/browser/home)
- [SRA](https://www.ncbi.nlm.nih.gov/sra)
- [GEO](https://www.ncbi.nlm.nih.gov/geo/)

# To test the module:

```
nextflow run main.nf \
    --input data/data.csv \
    --outdir data/ \
    -resume | tee headnode.log
```

`--input`: must be either a path to a samplesheet file, or a valid accession ID from the aforementioned sources.

`--outdir`: the path to output your downloaded files.

`--withSRA` (optional): download SRA files along with the GEO supplementary files.

You can modify the samplesheet in `data/` to test the module.

# Future improvements:

1/single-end & paired-end sanity check

2/curl options
