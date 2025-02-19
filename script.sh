nextflow run main.nf \
    --link GSE134213 \
    --outdir data/ \
    -resume 2>&1 | tee headnote.log