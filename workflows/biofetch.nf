#!/usr/bin/env nextflow
include { GET_GEO                                } from '../modules/local/get_geo'
include { GET_GEO_SRX                            } from '../modules/local/extract_srx'
include { GET_ENA                                } from '../modules/local/get_ena'
include { CURL_FILES_FROM_LINK                   } from '../modules/local/curl_files'
include { PREFETCH                               } from '../modules/local/prefetch'
include { FASTERQ_DUMP                           } from '../modules/local/fasterq_dump'
include { GET_SRA_GEO                            } from '../subworkflows/get_sra_geo'
include { CREATE_DESIGN                          } from '../modules/local/create_design'
include { FETCH_RUN_ACCESSION                    } from '../modules/local/fetch_run_accession'
include { FFQ                                    } from '../modules/nf-core/ffq/main'

workflow BIOFETCH {

    ch_accession                = Channel.empty()
    ch_project_accession        = Channel.empty()
    ch_run_accession            = Channel.empty()
    ch_retrieved_fastq          = Channel.empty()

    // Get accessions as channel
    if (file(params.input).exists()) {
        ch_samplesheet = Channel.fromPath( params.input, checkIfExists: true )
        ch_accession   = ch_accession.mix(ch_samplesheet.splitCsv( header: ["id"] ))
    } else {
        ch_accession   = ch_accession.mix( Channel.of(params.input).map{ value -> ["id" : value] } )
    }

    // Identify the source of ch_accession
    ch_accession.branch{ it ->
        def prefix = it.id.take(3)
        project:  prefix == "PRJ"
        study:    prefix != "PRJ"
    }.set { ch_branch_accession }

    ch_project_accession = ch_project_accession.mix(ch_branch_accession.project)
        .map { it ->
            def prefix = it.id.take(5)
            def source = [
                'PRJEB': 'ENA',
                'PRJNA': 'NCBI',
                'PRJDB': 'DDBJ'
            ][prefix] ?: 'UNKNOWN'
            return [ source: source, id: it.id ]
        }
    ch_run_accession = ch_run_accession.mix(ch_branch_accession.study)
        .map { it ->
            def prefix = it.id.take(3)
            def source = [
                'ERR': 'ENA',
                'GSE': 'NCBI',
                'DDB': 'DDBJ'
            ][prefix] ?: 'UNKNOWN'
            return [ source: source, run_id: it.id ]
        }

    FETCH_RUN_ACCESSION(
        ch_project_accession
    )

    FETCH_RUN_ACCESSION.out.accession
        .flatMap{ meta, accession_file ->
            def run_ids = accession_file.splitCsv( header: false ).flatten()
            run_ids.collect { run_id -> meta + [run_id: run_id] }
        }
        .set{ ch_fetch_run_accession_output }

    ch_run_accession = ch_run_accession.mix( ch_fetch_run_accession_output )
        .branch {
            ENA:  it.source  == "ENA"
            NCBI: it.source  == "NCBI"
        }

    // ch_run_accession.ENA.view()

    // EXTRACT_ACCESSION_FROM_PROJECT(
    //     ch_proj.PRJ
    // )

    // // divide asc_ids into databases
    // ch_asc_list.branch { 
    //     ENA:    it[0] == "ERR"
    //     SRA:    it[0] == "SRR"
    //     GEO:    it[0] == "GSE"
    //     DDBJ:   it[0] == "DDBJ"
    //     ENCODE: it[0] == "ENCODE"
    //     PRJ:    it[0] == "PRJ"
    // }.set{ result }

    // metadata features for ena report
    // def meta_features = []
    // for (item in params.ena_metadata) {
    //     if (item.value) {
    //         meta_features << item.key
    //     }
    // }
    // def ena_result      = "result="     + params.ena_result
    // def ena_fields      = "fields="     + meta_features.join(',')
    // def ena_format      = "format="     + params.ena_format
    // def ena_download    = "download="   + params.ena_download
    // def ena_limit       = "limit="      + params.ena_limit

    // def meta_id = [ena_result, 
    //     ena_fields, ena_format, 
    //     ena_download, ena_limit].join("&")

    // ch_enameta = Channel.of(meta_id)

    // // db down for SRA
    // if ( !params.skip_sra ) {
    //     PREFETCH(
    //         result.SRA
    //     )

    //     FASTERQ_DUMP(
    //         PREFETCH.out.prefetch_path
    //     )

    //     ch_retrieved_fastq.mix(FASTERQ_DUMP.out.fastq)
    // }

    // // db down for ENA
    // if ( !params.skip_ena ) {
    //     GET_ENA(
    //         result.ENA,
    //         ch_enameta.first()
    //     )
    //     ch_retrieved_fastq.mix(GET_ENA.out.fastq)
    // }

    // // db down for GEO
    // if ( !params.skip_geo ) {
    //     if ( !params.skip_geo_fastq ) {
    //         GET_SRA_GEO (
    //             result.GEO
    //         )
    //         ch_retrieved_fastq.mix(GET_SRA_GEO.out.fastq)
    //     } else {
    //         GET_GEO (
    //             result.GEO
    //         )            
    //     }
    // }


    // // make design file for downloaded fastq
    // ch_retrieved_fastq.view()

    // if ( !params.skip_design ) {    
    //     CREATE_DESIGN(
    //         ch_retrieved_fastq
    //     )
    // }
}