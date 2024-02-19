#!/bin/bash

# script to run diamond blastx against OMPdb and output blast-like tabular format

directory="/home/team2/group3/clust_data_group2/fna"

for file in "$directory"/*; do
    if [ -f "$file" ]; then
        outfile=${file##*/}
        outfile=${outfile%.*}
        diamond blastx --iterate --top 10 -d /home/team2/group3/LT/ompdb/OMPdb.dmnd -q $file -o /home/team2/group3/LT/ompdb/dmndblastx.$outfile.res.blast -f 6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore qframe qseq

    fi
done
