#!/usr/bin/env nextflow
process GET_GEO {
    tag "${asc_id}"

    container "community.wave.seqera.io/library/pip_geoparse_pandas:24e5b15a83985023"

    input:
    tuple val(meta), val(asc_id)

    output:
    tuple val(meta), val(asc_id), path("${asc_id}/")               , optional: true, emit: geo_data
    tuple val(meta), val(asc_id), path("${asc_id}/*.csv")          , optional: true, emit: geo_meta   

    script:
    def outdir              = params.outdir ?: "./"
    """
    #!/usr/bin/env python3

    import GEOparse
    import pandas as pd
    import os

    os.makedirs("./${asc_id}", exist_ok=True)

    gse = GEOparse.get_GEO(
        geo="${asc_id}"
    )

    gse.download_supplementary_files("${asc_id}/", 
            download_sra=True)
            
    metadata = pd.DataFrame()
    for gsm_name, gsm in gse.gsms.items():
        for key, value in gsm.metadata.items():
            metadata.loc[gsm_name, key] = ''.join(value)
    metadata.to_csv("${asc_id}/metadata.tsv", sep="\t", header = True)
        
    """

}