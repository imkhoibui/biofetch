#!/usr/bin/env nextflow
process PREFETCH {
    tag "${meta}"

    container 'community.wave.seqera.io/library/sra-tools:3.2.0--7131354b4197d164'

    input:
    tuple val(meta), val(asc_id)

    output:
    tuple val(meta), val(asc_id)            , emit: asc_id

    script:
    def prefix              = task.ext.prefix ?: "${meta}"
    def args                = task.ext.args ?: ""
    """
    prefetch \\
        $asc_id \\
        $args
    """
}