# Biofetch

Biofetch automatically download the fastq files from your samplesheet csv, as long as they have valid accession ID.

Available sites for retrieval: 

- [ENA](https://www.ebi.ac.uk/ena/browser/home)
- [NCBI](https://www.ncbi.nlm.nih.gov/)

# Running the pipeline:

```
nextflow run main.nf --input <design.csv/accession>
```

`--input` (required): either a `csv` file of accession or an accession string.

Current support accessions include:
- Project accession: PRJEB / PRJNA
- Run accession: ERR / SRR

## The input design file must be structured as:

```
SRRXXXXXXXX
PRJEBXXXXXX
ERRXXXXXXXX
PRJNAXXXXXX
```

No header nor extra columns is needed.

# Future improvements:

- [] Add support for [DDBJ](https://www.ddbj.nig.ac.jp/index-e.html) accessions.
- [] Create report to summarize the sequencing data downloaded
- [] Module to output custom config based on downloaded files