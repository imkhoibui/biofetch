#!/usr/bin/env nextflow
include { GET_ASC                                } from "${projectDir}/modules/local/fetch_asc.nf"
include { GET_GEO                                } from "${projectDir}/modules/local/get_geo.nf"
include { GET_GEO_SRX                            } from "${projectDir}/modules/local/extract_srx.nf"
include { GET_ENA                                } from "${projectDir}/modules/local/get_ena.nf"
include { CURL_FILES_FROM_LINK                   } from "${projectDir}/modules/local/curl_files.nf"
include { PREFETCH                               } from "${projectDir}/modules/local/prefetch.nf"
include { FASTERQ_DUMP                           } from "${projectDir}/modules/local/fasterq_dump.nf"
include { GET_SRA_GEO                            } from "${projectDir}/subworkflows/get_sra_geo.nf"

workflow BIOFETCH {

    // retrieves ASC list
    if (file(params.input).exists()) {
        ch_samplesheet = Channel.fromPath(
            params.input, checkIfExists: true
        )
        GET_ASC(ch_samplesheet)
        ch_asc_list = GET_ASC.out.asc.splitCsv( header: params.header )
    } else {

        ch_link = Channel.of(params.input)
        ch_asc_list = ch_link.map {
            link -> tuple(link.take(3), link)
        }
    }

    // divide asc_ids into databases
    ch_asc_list.branch { 
        ENA: it[0] == "ERR"
        SRA: it[0] == "SRR"
        GEO: it[0] == "GSE"
    }.set{ result }


    // metadata features for ena report
    def meta_features = []
    for (item in params.ena_metadata) {
        if (item.value) {
            meta_features << item.key
        }
    }
    def ena_result      = "result=" + params.ena_result
    def ena_fields      = "fields=" + meta_features.join(',')
    def ena_format      = "format=" + params.ena_format
    def ena_download    = "download=" + params.ena_download
    def ena_limit       = "limit=" + params.ena_limit

    def meta_id = [ena_result, 
        ena_fields, ena_format, 
        ena_download, ena_limit].join("&")

    ch_enameta = Channel.of(meta_id)


    // db down for SRA
    if ( !params.skip_sra ) {
        PREFETCH(
            result.SRA
        )

        FASTERQ_DUMP(
            PREFETCH.out.prefetch_path
        )
    }


    // db down for ERR
    if ( !params.skip_ena ) {
        GET_ENA(
            result.ENA,
            ch_enameta.first()
        )
    }

    // db down for GEO
    if ( !params.skip_geo ) {
        if ( !params.skip_geo_fastq ) {
            GET_SRA_GEO (
                result.GEO
            )
        } else {
            GET_GEO (
                result.GEO
            )            
        }
        // ch_geo_links = GET_GEO.out.geo_data.splitText()
        // CURL_FILES_FROM_LINK(
        //     ch_geo_links,
        //     GET_GEO.out.geo_folder
        // )
    }

}