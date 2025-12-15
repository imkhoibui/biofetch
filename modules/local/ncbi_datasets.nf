process NCBI_DATASETS {
    tag "${meta}"
    label 'process_low'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'oras://community.wave.seqera.io/library/ncbi-datasets-cli:18.12.0--d7f5d46fe05cae32':
        'community.wave.seqera.io/library/ncbi-datasets-cli:18.12.0--7f026d15fd01d7df' }"

    input:
    tuple val(meta), val(asc_id)

    output:
    tuple val(meta), 

    script:
    """
    ncbi 
    """
}