#!/usr/bin/env bash

pattern="^(GEO|ERR|SRA)[0-9]+"
echo $pattern
awk -v b="$pattern" -F',' '{
    for (i=1;i<=NF;i++) { 
        if ($i ~ b) { 
            print $i
        } 
    }
}' monocle-metadata.csv > asc_ids.csv,"$0 }' asc_ids.csv > asc_ids.csv
