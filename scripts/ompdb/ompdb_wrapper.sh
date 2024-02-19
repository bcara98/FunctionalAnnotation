#!/bin/bash

#wrapper for ompdb to run the python script.

# takes in one argument for output file location
while getopts "o:" option
do
		case $option in
			o) outdir=$OPTARG;;
		esac
done


directory="/home/team2/group3/LT/ompdb"

for file in "$directory"/*.blast; do
	if [ -f "$file" ]; then
		outfile=${file##*/}
		outfile=${outfile#*.}
		outfile=${outfile%%.*}
		./gff_from_blastx.py -blastx $file -source OMPdb -o $outdir/$outfile.cluster.ompdb
	fi
done
