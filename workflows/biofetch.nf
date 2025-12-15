#!/usr/bin/env nextflow
include { GET_GEO                                } from '../modules/local/get_geo'
include { GET_GEO_SRX                            } from '../modules/local/extract_srx'
include { GET_ENA                                } from '../modules/local/get_ena'
include { CURL_FILES_FROM_LINK                   } from '../modules/local/curl_files'
include { SRATOOLS_PREFETCH                      } from '../modules/nf-core/sratools/prefetch'
include { SRATOOLS_FASTERQDUMP                  } from '../modules/nf-core/sratools/fasterqdump'
include { GET_SRA_GEO                            } from '../subworkflows/get_sra_geo'
include { CREATE_DESIGN                          } from '../modules/local/create_design'
include { FETCH_RUN_ACCESSION                    } from '../modules/local/fetch_run_accession'
include { FFQ                                    } from '../modules/nf-core/ffq/main'
include { ENA_DATAGET                            } from '../modules/local/ena-browser-tools/enadataget'

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
            return [ source: source, id: it.id, run_id: it.id ]
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

    ENA_DATAGET(
        ch_run_accession.ENA
    )

    ch_run_accession.NCBI.view()

    SRATOOLS_PREFETCH(
        ch_run_accession.NCBI.map{ source, id, run_id -> [id, run_id]},
        Channel.empty(),
        Channel.empty()
    )
    SRATOOLS_FASTERQDUMP(
        SRATOOLS_PREFETCH.out.sra,
        Channel.empty(),
        Channel.empty()
    )

    // if ( !params.skip_design ) {    
    //     CREATE_DESIGN(
    //         ch_retrieved_fastq
    //     )
    // }
}