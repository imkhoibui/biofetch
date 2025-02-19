#!/usr/bin/env nextflow

process CURL_FILES_FROM_LINK {
    tag "${asc_id}"

    input:
    tuple val(meta), val(asc_id)

    output:
    tuple val(meta)

    script:
    """
    
    """
}