#!/usr/bin/env nextflow
process GET_ASC {
    label 'process_single'

    input:
    path(samplesheet)

    output:
    path("*_ids.csv")                               , emit: asc

    script:
    def asc_ids             = task.ext.asc_file ?: "asc_ids.csv"
    """
    #!/usr/bin/env bash

    pattern="^(GEO|ERR|SRR|SRA|GSE)[0-9]+"

    awk -v b="\$pattern" -F',' '{
        for (i=1;i<=NF;i++) { 
            if (\$i ~ b) { 
                print \$i
            } 
        }
    }' $samplesheet > "temp.csv"

    awk -F, '{ print substr(\$0, 1, 3)"," \$0 }' "temp.csv" > $asc_ids
    rm temp.csv
    """
}