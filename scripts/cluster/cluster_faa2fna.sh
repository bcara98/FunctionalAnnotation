#!/bin/bash

for file in /home/team2/group3/clust_data_group2/faa/*; do
    outfile=${file##*/}
    outfile=${outfile%%.*}
    cat /home/team2/group3/clust_data_group2/faa/$outfile.cluster.faa | grep "^>" | awk -F' # ' '{ print $1 ":" $2-1 "-" $3 }' | sed -e 's/_[0-9]*:/:/' > $outfile.cluster.bed
    sed -i -e 's/>//' $outfile.cluster.bed
    seqkit grep --pattern-file $outfile.cluster.bed /home/team2/group3/fna_gff_group2/fna/$outfile.fna > $outfile.cluster.fna
done

