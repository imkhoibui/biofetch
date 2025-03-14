nextflow run main.nf \
    --input GSE38003 \
    --single_end false \
    --outdir data/ \
    -resume 2>&1 | tee headnode.log