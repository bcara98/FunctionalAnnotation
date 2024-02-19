# annotating fna files with plasmid database

cd /home/team2/databases/plsdb 
conda create -n blast
conda activate blast
conda install -c bioconda blast

# index database
makeblastdb -in plsdb.fna -dbtype nucl 


# blastn test files to plsdb database

blastn -query /home/team2/group3/fna_gff_group2/fna/CGT2006.fna -db /home/team2/databases/plsdb/plsdb.fna -out /home/team2/group3/ID/CGT2006_plsdb.tsv -outfmt 6

blastn -query /home/team2/group3/fna_gff_group2/fna/CGT2010.fna -db /home/team2/databases/plsdb/plsdb.fna -out /home/team2/group3/ID/CGT2010_plsdb.tsv -outfmt 6

time blastn -query /home/team2/group3/fna_gff_group2/fna/CGT2044.fna -db /home/team2/databases/plsdb/plsdb.fna -out /home/team2/group3/ID/CGT2044_plsdb.tsv -outfmt 6
#real	0m9.746s
#user	0m9.529s
#sys	0m0.171s

time blastn -query /home/team2/group3/fna_gff_group2/fna/CGT2049.fna -db /home/team2/databases/plsdb/plsdb.fna -out /home/team2/group3/ID/CGT2049_plsdb.tsv -outfmt 6
#real	0m12.093s
#user	0m11.859s
#sys	0m0.163s


time blastn -query /home/team2/group3/fna_gff_group2/fna/CGT2060.fna -db /home/team2/databases/plsdb/plsdb.fna -out /home/team2/group3/ID/CGT2060_plsdb.tsv -outfmt 6
#real	0m9.621s
#user	0m9.423s
#sys	0m0.144s


# output files can be found at /home/team2/group3/ID
