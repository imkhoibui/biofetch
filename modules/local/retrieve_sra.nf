process GET_SRA_FROM_SRX  {
    tag "${geo_srx}"

    container "pegi3s/entrez-direct"

    input:
    val geo_srx

    output:
    path("*.csv"), emit: geo_sra

    script:
    def prefix              = task.ext.prefix ?: "${geo_srx}"

    """
    esearch -db sra -query ${geo_srx} | efetch -format runinfo | cut -d ',' -f 1 > ${prefix}.csv

    """
}