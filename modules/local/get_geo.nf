#!/usr/bin/env nextflow
process GET_GEO {
    tag "${asc_id}"
    label 'process_medium'

    container "community.wave.seqera.io/library/pip_geoparse_pandas:24e5b15a83985023"

    input:
    tuple val(meta), val(asc_id)

    output:
    // path("${asc_id}/data_urls.txt")                               , emit: geo_data
    path("${asc_id}_family*")                                        , emit: geo_docs
    tuple val(meta), val(asc_id), path("${asc_id}/*")                , emit: geo_folder   

    script:
    def base_data_link      = task.ext.geo_link ?: "https://ftp.ncbi.nlm.nih.gov/geo/series"
    def bucket              = "${asc_id}"[0..-4]
    def suppl_data_link     = "${base_data_link}/${bucket}nnn/${asc_id}/suppl/"
    def outdir              = params.outdir ?: "./"
    """
    python3 ${projectDir}/bin/get_geo.py --asc_id ${asc_id} --suppl_data_link ${suppl_data_link}
    gunzip ${asc_id}_family.soft.gz
        
    """
}