#!/usr/bin/env nextflow
process GET_ENA {
    tag "${asc_id}"

    input:
    tuple val(meta), val(asc_id)

    output:
    tuple val(meta), val(asc_id), path("*gz")

    script:
    def format             = task.ext.format ?: "fastq"
    def compress           = task.ext.compress ?: "gz"
    def sitelink           = task.ext.ena_link ?: "ftp://ftp.sra.ebi.ac.uk/vol1"
    def vol                = "${asc_id}".take(6)
    def bucket             = "00${asc_id[-1]}/"

    def filename_f         = "${asc_id}_1.${format}.${compress}"
    def filename_r         = "${asc_id}_2.${format}.${compress}"
    def filelink_f         = "${sitelink}/${format}/${vol}/${bucket}${asc_id}/${filename_f}"
    def filelink_r         = "${sitelink}/${format}/${vol}/${bucket}${asc_id}/${filename_r}"

    """
    curl -o $filename_f "$filelink_f"
    curl -o $filename_r "$filelink_r"
    """
}