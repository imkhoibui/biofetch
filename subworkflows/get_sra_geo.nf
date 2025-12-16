// include { GET_GEO                                } from '../modules/local/get_geo'
// include { GET_GEO_SRX                            } from '../modules/local/extract_srx'
// // include { GET_SRA_FROM_SRX                       } from '../modules/local/retrieve_sra'
// include { SRATOOLS_PREFETCH                      } from '../modules/nf-core/prefetch'
// include { SRATOOLS_FASTERQDUMP                   } from '../modules/nf-core/fasterq_dump'

workflow GET_SRA_GEO {
    // take:
    // ch_geo          // tuple val(meta), val(asc_id)

    // main:

    // GET_GEO(
    //     ch_geo
    // )

    // GET_GEO_SRX (
    //     GET_GEO.out.geo_docs
    // )

    // GET_GEO_SRX.out.geo_srx
    // | splitCsv(header: true)
    // | map { row -> tuple (row['Sample'],row['SRX']) }
    // | set { ch_geo_sra }
    
    // // GET_SRA_FROM_SRX (
    // //     ch_geo_sra
    // // )

    // // GET_SRA_FROM_SRX.out.geo_sra
    // // // | splitCsv(skip:1)
    // // | splitCsv()
    // // | set { ch_sra }

    // PREFETCH_GEO (
    //     ch_sra.map { meta, asc_id -> [ meta, asc_id[0] ] }
    // )
    
    // FASTERQ_DUMP_GEO (
    //     PREFETCH_GEO.out.prefetch_path
    // )

    // emit:
    //     fastq = FASTERQ_DUMP_GEO.out.fastq
}