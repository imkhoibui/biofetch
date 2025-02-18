#!/usr/bin/env nextflow
process GET_ENA {
    tag "${meta}"

    input:
    tuple val(meta), val(asc_id)

    output:
    tuple val(meta), val(asc_id)

    script:
    def format             = task.ext.format ?: "fastq"
    def compress           = task.ext.compress ?: ""
    def filename           = [asc_id, format, compress].join(".")

    """
    curl -o $filename 
    """
}