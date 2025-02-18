#!/usr/bin/env nextflow
process FASTERQ_DUMP {
    tag "${meta}"

    container 'community.wave.seqera.io/library/sra-tools:3.2.0--7131354b4197d164'

    input:
    tuple val(meta), val(asc_id)

    script:
    def prefix              = task.ext.prefix ?: "${meta}"
    def args                = task.ext.args ?: ""
    """
    fasterq-dump \\
        $asc_id \\
        $args
    """

}