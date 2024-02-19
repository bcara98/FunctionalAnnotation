#!/bin/bash

#initialization
DATABASE=/home/team2/databases/VFDB/VFDB_setA_pro.fas.gz
SAMPLE_DIR=/home/team2/group3/fna_gff_group2/fna
WEB_SERVER=0

#get ops
while getopts 'd:f:w:h' opt; do
 	case "$opt" in
	d)
	DATABASE=$OPTARG
	;;

	f)
	SAMPLE_DIR=$OPTARG
	;;

	w)
	WEB_SERVER=$OPTARG
	;;

	h)
    echo -e "Usage: bash $(basename $0) [options] \n[-d <protein database file>]: the gziped protein data base \n[-f <sample fna dir>]: the directory contains fna files for all samples \n[-w <integer 1 or 0>]: integer indicating wether the webserver simplified version should be run\n[-h ]: display the help page and exist"
	echo -e "\n"
	echo "Example:"
	echo "bash $(basename $0) -d /home/team2/databases/VFDB/VFDB_setA_pro.fas.gz -f /home/team2/group3/fna_gff_group2/fna -w 1"
	echo 
	exit 0
      	;;
  esac
done


#generate output dir
mkdir -p result/VFDB/gff



##################This section loop through all samples in SAMPLE_DIR and perform mmseqs blastx
for FILE in  $SAMPLE_DIR/*fna
do
	#get the sample name
	SAMPLE=`echo ${FILE} | rev | cut -d '/' -f1 | rev | cut -d '.' -f1`	

	#perform mmseqs blastx
	echo "----------------mmseqs start--------------"
	mmseqs easy-search ${FILE} ${DATABASE} ${SAMPLE}.m8 tmp --format-output query,target,pident,alnlen,mismatch,gapopen,qstart,qend,tstart,tend,evalue,bits,qframe,qseq -s 7.5 -v 0
	echo "mmseqs successeed"
	
	
	#generate the gff file
	echo "----------convert blastx fmt to gff--------"
	python3 mmseqs_gff_from_blastX.py -blastx ${SAMPLE}.m8 -source VFDB -o result/VFDB/gff/${SAMPLE}.gff #linsey's original script for gff generation
	#trim the seq id in gff
	cut -f1 result/VFDB/gff/${SAMPLE}.gff | sed 's/:.*//' | paste -d '\t' - <(cut -f2- result/VFDB/gff/${SAMPLE}.gff) > result/VFDB/gff/modified_document.txt
	mv result/VFDB/gff/modified_document.txt result/VFDB/gff/${SAMPLE}.gff
	

	##############This section perform extra file format conversion. For webserver purpose, we will skip this#########
	if [[ $WEB_SERVER -ne 1 ]]
	then
		#generate output directory
		mkdir -p result/VFDB/fna
		mkdir -p result/VFDB/faa


		#convert blast output to fna
		echo "---------convert blastx output to fna-----------"
		python3 mmseqs_blastx2fna.py --blast ${SAMPLE}.m8 --out result/VFDB/fna/${SAMPLE}.fna
		echo "conversion successeed"

		#translate fna to faa
		echo "--------translate fna to faa---------------"
		transeq result/VFDB/fna/${SAMPLE}.fna result/VFDB/faa/${SAMPLE}.faa -sformat pearson
		echo "transeq successeed"
	fi
done

wait


#remove temporary files
rm *m8
rm -r tmp
