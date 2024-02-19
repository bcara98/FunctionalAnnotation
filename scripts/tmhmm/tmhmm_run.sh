#!/bin/bash

directory="/home/team2/group3/clust_data_group2/faa"

for file in "$directory"/*; do
    if [ -f "$file" ]; then
        outfile=${file##*/}
        outfile=${outfile%.*}
        tmhmm $file > /home/team2/group3/LT/tmhmm/tmhmm_$outfile.out
    fi
done
