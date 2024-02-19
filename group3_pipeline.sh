#!/bin/bash

# Team2 functional annotation pipeline

CLUSTER=1
OMPDB=0
TMHMM=0
SIGNALP=0
VFDB=''
PHROGs=''
PLSDB=''
fna_dir=''
EGGNOG=0
COG=0
CARD=0
# takes in arguments

while getopts "ho:t:v:p:n:s:ecr" option; do
	case $option in
		h) echo -e "command line options and parameters:\n-c: clustering \n-o <directory>: runs ompdb with diamond, specify output directory\n-t <directory>: runs tmhmm, specify output directory\n-v <file>: a VFDB protein database gz file\n-p <file>: a PHROGs protein database tar.gz file\n-n: <directory> the directory that stores the fna files for all samples\n-e: EGGNOG database\n-c: COG database\n-r: CARD database\n-z: <file>: a PLSDB database fna file"
		o) ompdb_outdir="${OPTARG}"; OMPDB=1;;
		t) tmhmm_outdir="${OPTARG}"; TMHMM=1;;
		v) VFDB="${OPTARG}";;
		p) PHROGs="${OPTARG}";;
		n) fna_dir="${OPTARG}";;
		s) signalp="${OPTARG}"; SIGNALP=1;;
		e) EGGNOG=1;;
		c) COG=1;;
		r) CARD=1;;
		z) PLSDB="${OPTARG}";;
	esac
done

cd /home/team2/group3/scripts

#### CLUSTERING WITH DIAMOND ####

if [ "$CLUSTER" -eq 1 ]; then
	conda activate diamond
	./cluster/cluster_dmnd.sh
	./cluster/cluster_faa2fna.sh
	conda deactivate
fi


#### OMPDB ####

if [ "$OMPDB" -eq 1 ]; then
	conda activate diamond
	./ompdb/ompdb_blastx.sh
	./ompdb/ompdb_wrapper.sh -o $ompdb_outdir
	conda deactivate

	conda activate emboss
	for file in $ompdb_outdir/*.fna; 
		do transeq $ompdb_outdir/$file ${file%.*}.faa -sformat pearson; 
	done
	conda deactivate
fi


#### TMHMM2.0 ####

if [ "$TMHMM" -eq 1 ]; then
	export PATH="/home/team2/bin/tmhmm/tmhmm-2.0c/bin:$PATH"
	./tmhmm/tmhmm_run.sh
	./tmhmm/tmhmm_wrapper.sh -o $tmhmm_outdir

	conda activate bedtools
	./tmhmm/tmhmm_gff2fna.sh -o $tmhmm_outdir -gff $tmhmm_outdir
	conda deactivate

	conda activate emboss
	for file in $tmhmm_outdir/*.fna; 
		do transeq $tmhmm_outdir/$file ${file%.*}.faa -sformat pearson; 
	done
	conda deactivate
fi



#####VFDB #######
if [[ "$VFDB" != '' ]] && [[ "$fna_dir" != '' ]]; then
	conda activate virulence
	sh virulence_mmseqs.sh -d ${VFDB} -f ${fna_dir}	
	conda deactivate
fi




####PHROGs#########
if [[ "$PHROGs" != '' ]] && [[ "$fna_dir" != '' ]]; then
	conda activate prophage
	sh prophage_mmseqs.sh -d ${VFDB} -f ${fna_dir}
	conda deactivate
fi



#####SignalP6.0#######
if [ "$SIGNALP" -eq 1 ]; then
    conda activate signalp
    gunzip -r /home/team2/group3/data_from_group2/*.faa.gz
    sh /home/team2/group3/scripts/signalp/signalp.sh  
    conda deactivate
fi


#### COG ####
if [[ "$COG" -eq 1 ]]; then
	conda activate emboss
	bash cog.sh
	conda deactivate
fi

#### EGGNOG ####
if [[ "$EGGNOG" -eq 1 ]]; then
	conda activate emboss
	bash eggnog.sh
	conda deactivate
fi


#### CARD ####
if [[ "$CARD" -eq 1 ]]; then
	conda activate emboss
	bash card.sh
	conda deactivate
fi

####PLSDB#########
if [[ "$PLSDB" != '' ]] && [[ "$fna_dir" != '' ]]; then
	conda activate plasmid
	sh plasmids_mmseqs2.sh -d ${VFDB} -f ${fna_dir}
fi


