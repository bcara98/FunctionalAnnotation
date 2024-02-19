#!/bin/bash

# takes in one argument for output file location
while getopts "o:" option
do
		case $option in
			o) outdir=$OPTARG;;
		esac
done


directory="/home/team2/group3/LT/tmhmm"

for file in "$directory"/*.out; do
	if [ -f "$file" ]; then
		faafile=${file##*/}
		faafile=${faafile%%.*}
		faafile=${faafile##*_}
		./tmhmmout_convert.py -tsv $file -faa /home/team2/group3/clust_data_group2/faa/$faafile.cluster.faa -o $outdir/$faafile.cluster.tmhmm.gff
	fi
done
