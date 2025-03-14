include { GET_GEO                                } from "${projectDir}/modules/local/get_geo.nf"
include { GET_GEO_SRX                            } from "${projectDir}/modules/local/extract_srx.nf"
include { GET_SRA_FROM_SRX                       } from "${projectDir}/modules/local/retrieve_sra.nf"
include { PREFETCH as PREFETCH_GEO               } from "${projectDir}/modules/local/prefetch.nf"
include { FASTERQ_DUMP as FASTERQ_DUMP_GEO       } from "${projectDir}/modules/local/fasterq_dump.nf"

workflow GET_SRA_GEO {
    take:
    ch_geo          // tuple val(meta), val(asc_id)

    main:

    GET_GEO(
        ch_geo
    )

    GET_GEO_SRX (
        GET_GEO.out.geo_docs
    )

    GET_GEO_SRX.out.geo_srx
    | splitCsv(header: true)
    | map { row -> tuple (row['Sample'],row['SRX']) }
    | set { ch_geo_sra }
    
    GET_SRA_FROM_SRX (
        ch_geo_sra
    )

    GET_SRA_FROM_SRX.out.geo_sra
    | splitCsv(skip:1)
    | set { ch_sra }

    PREFETCH_GEO (
        ch_sra.map { meta, asc_id -> [ meta, asc_id[0] ] }
    )
    
    FASTERQ_DUMP_GEO (
        PREFETCH_GEO.out.prefetch_path
    )
}