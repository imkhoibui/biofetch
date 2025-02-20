nextflow run main.nf \
    --input ERR14129305 \
    --outdir data/ \
    -resume 2>&1 | tee headnote.log