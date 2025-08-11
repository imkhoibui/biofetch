process CREATE_DESIGN {
    label 'process_single'

    container "community.wave.seqera.io/library/pip_geoparse_pandas:24e5b15a83985023"
    
    input:
    tuple val(meta), path(fastq_1), path(fastq_2)

    output:
    path "*design.csv"              , emit: design

    script:
    """
    python ${projecteDir}/bin/create_design.py \\
        --fastq_1 ${fastq_1} \\
        --fastq_2 ${fastq_2} \\
        --meta ${meta} \\
        --output design.csv
    """
}