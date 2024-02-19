#!/bin/bash

# conda packages used: blast, bedtools, emboss 

# real	5m51.969s	user	19m56.887s	sys	0m14.515s

makeblastdb -in /home/team2/databases/plsdb/plsdb.fna -dbtype nucl -parse_seqids

cd /home/team2/group3/fna_gff_group2/fna

for file in *.fna;
do
        file=$file
        
        # blast
        blastn -query $file -db /home/team2/databases/plsdb/plsdb.fna -out /home/team2/group3/all_results/plasmids/gff/blast/${file%.*} -max_target_seqs 1 -num_threads 4 -evalue 1e-6 -outfmt 6

        # convert tsv to gff
        bash /home/team2/group3/ID/blastoutput2gff.sh /home/team2/group3/all_results/plasmids/gff/blast/${file%.*}
        mv /home/team2/group3/all_results/plasmids/gff/blast/*.gff /home/team2/group3/all_results/plasmids/gff

        # convert gff to bedtools to generate fna and faa files
        bash /home/team2/group3/ID/blast2bed.sh /home/team2/group3/all_results/plasmids/gff/blast/${file%.*}
        
        # get fasta sequences from database that correspond to gff
        bedtools getfasta -fi /home/team2/databases/plsdb/plsdb.fna -bed /home/team2/group3/all_results/plasmids/gff/blast/${file%.*}\.bed -name > /home/team2/group3/all_results/plasmids/fna/${file%.*}\.fna;
        
        # translate fasta sequences into amino acid sequences
        transeq -sequence /home/team2/group3/all_results/plasmids/fna/${file%.*}\.fna -outseq /home/team2/group3/all_results/plasmids/faa/${file%.*}\.faa --frame 6 -sformat pearson
done
