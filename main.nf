#!/usr/bin/env nextflow

include { BIOFETCH                              } from "${projectDir}/modules/local/biofetch.nf"

workflow {

    BIOFETCH()
}