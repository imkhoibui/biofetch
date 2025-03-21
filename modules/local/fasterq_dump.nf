#!/usr/bin/env nextflow
process FASTERQ_DUMP {
    tag "${asc_id}"
    label 'process_high'

    container 'community.wave.seqera.io/library/sra-tools:3.2.0--7131354b4197d164'

    input:
    tuple val(meta), val(asc_id), path(prefetch_path)

    output:
    tuple val(meta), val(asc_id), path("*fastq.gz")

    script:
    def prefix              = task.ext.prefix ?: "${meta}"
    def args                = task.ext.args ?: ""
    """
    fasterq-dump \\
        $prefetch_path \\
        $args

    gzip *fastq
    """

}