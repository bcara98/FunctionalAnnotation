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
      	echo "Usage: $(basename $0) [-d <protein database file> [-f <sample fna dir>] "
	echo "Example:"
	echo "sh $(basename $0) -d /home/team2/databases/phrogs/FAA_phrog.tar.gz -f /home/team2/group3/fna_gff_group2/fna"
	exit 0
      	;;
  esac

done

mkdir -p result/gff
mkdir -p result/fna
mkdir -p result/faa




#unzip the database
tar -zxf  $DATABASE -C $PWD

#generate database
for FILE in FAA_phrog/* 
do

        cat $FILE >> phrog.faa
done
mmseqs createdb phrog.faa phrogDB




#loop through 50 files
for FILE in $SAMPLE_DIR/*fna
do
        SAMPLE=`echo ${FILE} | rev | cut -d '/' -f1 | rev | cut -d '.' -f1`

        #mmseqs most sensitive search
        mmseqs easy-search ${FILE} phrogDB ${SAMPLE}.m8 tmp --format-output query,target,pident,alnlen,mismatch,gapopen,qstart,qend,tstart,tend,evalue,bits,qframe,qseq -s 7.5 -v 0

        #convert blast output to gff
        mmseqs_gff_from_blastX.py -blastx ${SAMPLE}.m8 -source PHROGs -o result/gff/${SAMPLE}.gff

        #convert blast output to fna
        mmseqs_blastx2fna.py --blast ${SAMPLE}.m8 --out result/fna/${SAMPLE}.fna

        #translate fna to faa
        transeq result/fna/${SAMPLE}.fna result/faa/${SAMPLE}.faa -sformat pearson
done





wait

rm *m8
rm -r tmp
