process GET_SRA_FROM_SRX  {
    tag "${geo_srx}"
    label 'process_high'

    container "pegi3s/entrez-direct"

    input:
    tuple val(meta), val(geo_srx)

    output:
    tuple val(meta), path("*.csv"), emit: geo_sra
    tuple val(meta), path("*.txt"), emit: geo_log

    script:
    def prefix              = task.ext.prefix ?: "${geo_srx}"

    """
    # Function to retry a command with exponential backoff
    retry_command() {
        local cmd="\$1"
        local max_attempts=3
        local attempt=1
        local delay=5

        while [ \$attempt -le \$max_attempts ]; do
            echo "Attempt \$attempt: Running \$cmd" >> ${prefix}_log.txt
            eval \$cmd && return 0
            echo "Attempt \$attempt failed. Retrying in \$delay seconds..." >> ${prefix}_log.txt
            sleep \$delay
            attempt=\$(( attempt + 1 ))
            delay=\$(( delay * 2 ))  # Exponential backoff
        done

        echo "All attempts failed for ${geo_srx}." >> ${prefix}_log.txt
        return 1
    }

    # First attempt: Use NCBI Entrez Direct
    ncbi_cmd="esearch -db sra -query ${geo_srx} | efetch -format runinfo | cut -d ',' -f 1 | tail -n +2 > ${prefix}.csv"
    retry_command "\$ncbi_cmd"
    
    # Check if NCBI succeeded
    if [ -s "${prefix}.csv" ]; then
        echo "NCBI search successful for ${geo_srx}" >> ${prefix}_log.txt
        exit 0
    fi

    echo "NCBI search failed. Falling back to ENA API..." >> ${prefix}_log.txt

    # Second attempt: Use ENA API
    ena_cmd="curl -s 'https://www.ebi.ac.uk/ena/portal/api/filereport?accession=${geo_srx}&result=read_run&fields=run_accession' | tail -n +2 | tr '\t' '\n' > ${prefix}.csv"
    retry_command "\$ena_cmd"

    # Check if ENA succeeded
    if [ -s "${prefix}.csv" ]; then
        echo "ENA search successful for ${geo_srx}" >> ${prefix}_log.txt
        exit 0
    fi

    echo "Both NCBI and ENA failed for ${geo_srx}" >> ${prefix}_log.txt
    exit 1

    """
}