#!/bin/bash

### testing MMseqs2

## conda environment mmseqs
## conda install -c conda-forge -c bioconda mmseqs2

# psrecord "conda run -n mmseqs ./mmseqs_clust_test.sh" --log mmseqs_clust_test.log
# 20.22 seconds
# conda run -n mmseqs ./mmseqs_clust_test.sh

directory="/home/team2/group3/test_files"

## easy cluster example: mmseqs easy-cluster examples/DB.fasta clusterRes tmp

for file in "$directory"/*; do
    if [ -f "$file" ]; then
        outfile=${file##*/}
        outfile=${outfile%.*}
        mmseqs easy-cluster $file mmseqs_$outfile tmp
    fi
done


