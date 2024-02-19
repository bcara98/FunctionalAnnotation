#!/bin/bash


# takes in one argument for output file location
while getopts "o:gff:" option
do
        case $option in
            o) outdir=$OPTARG;;
            gff) gffdir=$OPTARG;;
        esac
done


# convert tmhmm.gff file into sequence using bedtools

directory="/home/team2/group3/LT/tmhmm"

for file in "$directory"/*.gff; do
    if [ -f "$file" ]; then
	    outfile=${file##*/}
    	outfile=${outfile%%.*}
    	cat $gffdir/$outfile.cluster.tmhmm.gff | sed -e 's/_[0-9]*\t/\t/' | awk -F'\t' -v OFS='\t' '{ print $1, $4, $5, $1":"$4"-"$5"; "$2";"$3";"$9 }'  > /home/team2/group3/LT/tmhmm/$outfile.cluster.tmhmm.bed
    	bedtools getfasta -fi /home/team2/group1/results/Contigs/$outfile.fasta -bed /home/team2/group3/LT/tmhmm/$outfile.cluster.tmhmm.bed -fo $outdir/$outfile.cluster.tmhmm.fna -nameOnly
    fi
done

