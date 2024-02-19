#!/bin/bash

# CPU usage: psrecord "conda run -n diamond ./diamond_clust_test.sh" --log diamond_clust_test.log
# 4.12 seconds
# conda run -n diamond ./cluster_dmnd.sh

# set the directory path
#directory="/home/team2/group3/clust_data_group2/diamond"
directory="/home/team2/group3/test_files"

# loop through the files in the directory

# unzipping files
for file in "$directory"/*; do
    if [ -f "$file" ]; then
        echo "unzipping $file"
        gunzip $file
    fi
done


# clustering then generating representative seqs file: uniq.$filename.cluster.faa 
for file in "$directory"/*; do
    if [ -f "$file" ]; then
        outfile=${file##*/}
        outfile=${outfile%.*}
        diamond cluster -d $file -o ./$outfile.cluster.tsv --approx-id 50 -M 64G --header
        cat $outfile.cluster.tsv | cut -f1 | uniq > uniq.$outfile.cluster.tsv
        seqkit grep --pattern-file uniq.$outfile.cluster.tsv $file > dmnd.$outfile.cluster.faa
    fi
done

#zipping files
for file in "$directory"/*; do
    if [ -f "$file" ]; then
        echo "zipping $file"
        gzip $file
    fi
done


#i=0
#while [ $i -lt 5 ]; do
#    for file in "$directory"/*; do
#        if [ -f "$file" ]; then
#            diamond cluster -d $file -o "${file%.*}".cluster.tsv --approx-id 50 -M 64G --header
#            cat "${file%.*}".cluster.tsv | cut -f1 | uniq > uniq."${file%.*}".cluster.tsv
#            seqkit grep --pattern-file uniq."${file%.*}".cluster.tsv /home/team2/group3/data_from_group2/CGT2364.faa > uniq."${file%.*}".cluster.faa
#            i=$[$i+1]
#        fi
#    done




