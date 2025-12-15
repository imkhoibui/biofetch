process FETCH_RUN_ACCESSION {
    tag "${meta.id}"
    label 'process_low'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'oras://community.wave.seqera.io/library/entrez-direct_curl:b4ef66c35d9a3323':
        'community.wave.seqera.io/library/entrez-direct_curl:a21faa318ca2ea3b' }"

    input:
    val(meta)

    output:
    tuple val(meta), path("${meta.id}_accession.csv") , emit: accession 

    script:
    def ena_prj_url = params.ena_prj_url ?: "https://www.ebi.ac.uk/ena/portal/api/search?result=read_run&query=study_accession=${meta.id}&fields=run_accession&format=csv"
    if ( meta.source == "ENA")
        """
        curl -s "${ena_prj_url}" \\
        | tail -n +2 > ${meta.id}_accession.csv
        """
    else if ( meta.source == "NCBI")
        """
        esearch -db sra -query "${meta.id}" \\
        | efetch -format runinfo \\
        | cut -d ',' -f 1 \\
        | tail -n +2 > ${meta.id}_accession.csv
        """
}