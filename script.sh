nextflow run main.nf \
    --link  GSE123124 \
    --outdir data/ \
    -resume 2>&1 | tee headnote.log