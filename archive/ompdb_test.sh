#!/bin/bash

# testing ompdb finding hits on test files with diamond

# creating a diamond-formatted database file
#    ./diamond makedb --in reference.fasta -d reference
# running a search in blastp mode
#    ./diamond blastp -d reference -q queries.fasta -o matches.tsv

# OMPdb location: /home/team2/databases/OMPdb/OMPdb.fasta.gz
# making diamond database: diamond makedb --in /home/team2/databases/OMPdb/OMPdb.fasta -d OMPdb

# running the test file against the ompdb with diamond 
## diamond blastp -d OMPdb.dmnd -q /home/team2/group3/LT/diamond/dmnd.CGT2044.cluster.faa -o dmnd.CGT2044.ompdb.matches.tsv
# diamond blastp --iterate --top 10 -d /home/team2/group3/LT/ompdb/OMPdb.dmnd -q /home/team2/group3/LT/diamond/dmnd.CGT2044.cluster.faa -o ./diamond/dmnd.CGT2044.ompdb.top10res.sam -f 101


# psrecord "./ompdb_test.sh" --log dmnd_ompdb_blastp_test.log
# 360 s

# creating a loop for test files 
directory="/home/team2/group3/test_files"

for file in "$directory"/*; do
    if [ -f "$file" ]; then
        outfile=${file##*/}
        outfile=${outfile%.*}
        diamond blastp --iterate --top 10 -d /home/team2/group3/LT/ompdb/OMPdb.dmnd -q $file -o /home/team2/group3/LT/ompdb/dmnd.$outfile.res.blast -f 6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore qframe qseq

    fi
done

# can use Uniprot to map the IDs: https://www.uniprot.org/id-mapping
# generate list of IDs: cat dmnd.CGT2006.res.blast | awk '$2 != "*"' | cut -f2 > ompdb_list.txt 





'''
Blast -6 output:
qseqid	sseqid	pident	length	mismatch	gapopen	qstart	qend	sstart	send	evalue	bitscore

gff output: 
seqname	source	feature	start	end	score	strand	frame	attribute

qseqid 'OMPDb' sseqid qstart	qend	.	.	


SAM file:
qname	flag	rname	pos	mapq	cigar	rnext	pnext	tlen	seq	qual

qname	'OMPdb'	rname	pos	pos+tlen	flag	.	.	.

'''

