nextflow run main.nf \
    --input ERR980217 \
    --single_end false \
    --outdir data/ \
    -resume 2>&1 | tee headnode.log