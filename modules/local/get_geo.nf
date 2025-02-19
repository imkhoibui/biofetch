#!/usr/bin/env nextflow
process GET_GEO {
    tag "${asc_id}"

    container "community.wave.seqera.io/library/pip_geoparse:1d7c4ccd44e318cf"

    input:
    tuple val(meta), val(asc_id)

    output:
    tuple val(meta), path("${asc_id}/*.gz")              , emit: geo

    script:
    def outdir              = params.outdir ?: "./"
    """
    #!/usr/bin/env python3

    import GEOparse
    import os

    os.makedirs("./${asc_id}", exist_ok=True)

    gse = GEOparse.get_GEO(
        geo="${asc_id}",
        destdir="./${asc_id}"
    )
    """

}