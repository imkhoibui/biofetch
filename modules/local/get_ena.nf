#!/usr/bin/env nextflow
process GET_ENA {
    tag "${asc_id}"

    input:
    tuple val(meta), val(asc_id)
    val ena_meta

    output:
    tuple val(meta), val(asc_id), path("${asc_id}/*gz")       , emit: ena_data
    tuple val(meta), val(asc_id), path("*tsv")      , emit: ena_meta

    script:
    def format             = task.ext.format ?: "fastq"
    def compress           = task.ext.compress ?: "gz"
    def base_data_link     = task.ext.ena_link ?: "ftp://ftp.sra.ebi.ac.uk/vol1"
    def base_meta_link     = task.ext.ena_metada_link ?: "https://www.ebi.ac.uk/ena/portal/api/filereport?"
    def vol                = "${asc_id}".take(6)
    def bucket             = "${asc_id}".length() == 9 ? "" : "00${asc_id[-1]}/"
    def single_end         = params.single_end ?: false

    def filename_f, filename_r, filelink_f, filelink_r
    if (!single_end) {
        filename_f         = "${asc_id}_1.${format}.${compress}"
        filename_r         = "${asc_id}_2.${format}.${compress}"
        filelink_f         = "${base_data_link}/${format}/${vol}/${bucket}${asc_id}/${filename_f}"
        filelink_r         = "${base_data_link}/${format}/${vol}/${bucket}${asc_id}/${filename_r}"
    } else {
        filename_f         = "${asc_id}.${format}.${compress}"
        filelink_f         = "${base_data_link}/${format}/${vol}/${bucket}${asc_id}/${filename_f}"
    }

    def meta_id            = "accession=${asc_id}&${ena_meta}"
    def metadata_file      = "${asc_id}_metadata.tsv"
    def metadata_link      = "${base_meta_link}${meta_id}"

    """
    mkdir ${asc_id}
    curl -o "${asc_id}/${filename_f}" "${filelink_f}"
    if ! $single_end ; then 
        curl -o "${asc_id}/${filename_r}" "${filelink_r}" 
    fi
    curl -o "${metadata_file}" "${metadata_link}"
    """
}


