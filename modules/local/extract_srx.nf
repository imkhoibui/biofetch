process GET_GEO_SRX {
    tag "${geo_docs.baseName}"
    label 'process_single'

    container "community.wave.seqera.io/library/pip_geoparse_pandas:24e5b15a83985023"

    input:
    path(geo_docs)

    output:
    path("*.csv"), emit: geo_srx

    script:
    def prefix              = task.ext.prefix ?: "${geo_docs.baseName}"

    """
    python3 ${projectDir}/bin/extract_srx.py ${geo_docs} ${prefix}_srx.csv

    """
}