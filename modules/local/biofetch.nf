#!/usr/bin/env nextflow

include { GET_ASC                                } from "${projectDir}/modules/local/fetch_asc.nf"

include { GET_ENA                                } from "${projectDir}/modules/local/get_ena.nf"
include { PREFETCH                               } from "${projectDir}/modules/local/prefetch.nf"
include { FASTERQ_DUMP                           } from "${projectDir}/modules/local/fasterq_dump.nf"

workflow BIOFETCH {

    // channels
    ch_samplesheet = Channel.fromPath(
        params.samplesheet, checkIfExists: true
    )
    
    GET_ASC(ch_samplesheet)

    ch_asc_list = GET_ASC.out.asc.splitCsv( header: false )

    ch_asc_list.branch { 
            ENA: it[0] == "ERR"
            SRA: it[0] == "SRA"
        }.set{ result }

    // db down for SRA

    PREFETCH(
        result.SRA
    )
    FASTERQ_DUMP(
        PREFETCH.out.asc_id
    )

    // ERR

    GET_ENA(
        result.ENA
    )

    


}