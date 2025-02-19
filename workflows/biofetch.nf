#!/usr/bin/env nextflow
include { GET_ASC                                } from "${projectDir}/modules/local/fetch_asc.nf"
include { GET_GEO                                } from "${projectDir}/modules/local/get_geo.nf"
include { GET_ENA                                } from "${projectDir}/modules/local/get_ena.nf"
include { CURL_FILES_FROM_LINK                   } from "${projectDir}/modules/local/curl_files.nf"
include { PREFETCH                               } from "${projectDir}/modules/local/prefetch.nf"
include { FASTERQ_DUMP                           } from "${projectDir}/modules/local/fasterq_dump.nf"

workflow BIOFETCH {
    // retrieves ASC list
    if (params.link != null) {
        ch_link = Channel.of(params.link)
        ch_asc_list = ch_link.map {
            link -> tuple(link.take(3), link)
        }

    } else if (params.samplesheet != null) {
        ch_samplesheet = Channel.fromPath(
            params.samplesheet, checkIfExists: true
        )
        GET_ASC(ch_samplesheet)
        ch_asc_list = GET_ASC.out.asc.splitCsv( header: params.header )
    }
    // divide database
    ch_asc_list.branch { 
        ENA: it[0] == "ERR"
        SRA: it[0] == "SRA"
        GEO: it[0] == "GSE"
    }.set{ result }

    // db down for SRA
    PREFETCH(
        result.SRA
    )
    FASTERQ_DUMP(
        PREFETCH.out.asc_id
    )

    // db down for ERR
    GET_ENA(
        result.ENA
    )

    // db down for GEO
    GET_GEO(
        result.GEO
    )
}