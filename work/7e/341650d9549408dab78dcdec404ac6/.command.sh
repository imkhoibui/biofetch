#!/usr/bin/env bash

pattern="^(GEO|ERR|SRA)[0-9]+"

awk -v b="$pattern" -F',' '{
    for (i=1;i<=NF;i++) { 
        if ($i ~ b) { 
            print $i
        } 
    }
}' monocle-metadata.csv > "temp.csv"

awk -F, '{ print substr($0, 1, 3)"," $0 }' "temp.csv" > asc_ids.csv
rm temp.csv
