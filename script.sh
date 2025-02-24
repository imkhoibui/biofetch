nextflow run main.nf \
    --input GSE22001 \
    --single_end false \
    --outdir data/ \
    -resume 2>&1 | tee headnode.log