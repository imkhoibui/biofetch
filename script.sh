nextflow run main.nf \
    --samplesheet data/data.csv \
    --outdir data/ \
    -resume 2>&1 | tee headnote.log