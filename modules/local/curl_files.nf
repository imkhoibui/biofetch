#!/usr/bin/env nextflow

process CURL_FILES_FROM_LINK {
    input:
    val link
    tuple val(meta), val(asc_id), path("${asc_id}/")

    output:
    val("${asc_id}/*")

    script:
    """
    #!/usr/bin/bash 

    cd $asc_id
    curl -O $link
    cd ..
    """
}