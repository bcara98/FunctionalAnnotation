#!/bin/bash

directory="/home/team2/group3/files_from_group2"

# unzipping files
for file in "$directory"/*; do
    if [ -f "$file" ]; then
        echo "unzipping $file"
        gunzip $file
    fi
done

mkdir cluster

# clustering then generating representative seqs file: uniq.$filename.cluster.faa 
for file in "$directory"/*; do
    if [ -f "$file" ]; then
        outfile=${file##*/}
        outfile=${outfile%.*}
        diamond cluster -d $file -o ./$outfile.cluster.tsv --approx-id 50 -M 64G --header
        cat $outfile.cluster.tsv | cut -f1 | uniq > uniq.$outfile.cluster.tsv
        seqkit grep --pattern-file uniq.$outfile.cluster.tsv $file > /home/team2/group3/clust_data_group2/$outfile.cluster.faa
    fi
done

#zipping files
for file in "$directory"/*; do
    if [ -f "$file" ]; then
        echo "zipping $file"
        gzip $file
    fi
done

