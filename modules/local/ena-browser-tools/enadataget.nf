process ENA_DATAGET {
    tag "${meta}"
    label 'process_low'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'oras://community.wave.seqera.io/library/enabrowsertools:1.7.2--0d3f6123db2ffdf5':
        'community.wave.seqera.io/library/enabrowsertools:1.7.2--da63041b2d7f672c' }"

    input:
    tuple val(meta), val(asc_id)

    output:
    tuple val(meta), path("*.fastq.gz")         , emit: fastq

    script:
    """
    enaDataGet \\ 
        -f fastq \\
        ${asc_id}
    """
}