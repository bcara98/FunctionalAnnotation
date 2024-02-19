#!/bin/bash

while getopts 'd:f:h' opt; do
 	case "$opt" in
	d)
	DATABASE=$OPTARG
	;;

	f)
	SAMPLE_DIR=$OPTARG
	;;

	h)
    echo "Usage: $(basename $0) [-d <nucleotide database file> [-f <sample fna dir>] "
	echo "Example:"
	echo "sh $(basename $0) -d /home/team2/databases/plsdb/plsdb.fna -f /home/team2/group3/fna_gff_group2/fna"
	exit 0
      	;;
  esac

# Create database from PLSDB fasta file
mmseqs createdb plsdb.fna PLSDB

# Index database to speed up process. Not necessary if only doing a few files, very useful for our purposes
mmseqs createindex PLSDB tmp --search-type 3

# Create result directories
mkdir -p result/gff
mkdir -p result/fna
mkdir -p result/faa

# Loop through fna files from gene prediction
for FILE in $SAMPLE_DIR/*fna
do
        SAMPLE=`echo ${FILE} | rev | cut -d '/' -f1 | rev | cut -d '.' -f1`

        # blastn-like search with MMseqs2, search type 3 for nucleotide database
        mmseqs easy-search ${FILE} /home/team2/databases/plsdb/PLSDB ${SAMPLE}.m8 tmp --search-type 3 --format-output query,target,pident,alnlen,mismatch,gapopen,qstart,qend,tstart,tend,evalue,bits,qframe,qseq -s 7.5 -v 0

        # Take mmseq blast-like output and convert to gff3
        ./mmseqs_gff_from_blastn.py -blastx ${SAMPLE}.m8 -source PLSDB -o result/gff/${SAMPLE}.gff

        # Take mmseq blast-like output and get nucleotide sequence for each hit
        ./mmseqs_blastn2fna.py --blast ${SAMPLE}.m8 --out result/fna/${SAMPLE}.fna

        # Convert nucleotide sequences to amino acid sequences
        transeq result/fna/${SAMPLE}.fna result/faa/${SAMPLE}.faa -sformat pearson

done


# Results can be found at /home/team2/group3/all_results/plasmids
