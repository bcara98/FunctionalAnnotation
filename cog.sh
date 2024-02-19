# time taken to run all 50 files: real	12m27.830s user	84m10.953s sys	2m19.030s 

#!/bin/bash

for f in CGT****.fna; do

# annotating the files

  ./diamond blastx --db /home/team2/databases/COG2020/cog-20-db.dmnd -q $f -o ${f%.fna}.tsv --outfmt 6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore qframe qseq

# generating gff and fna files

  python3 gff_from_blastX.py -blastx ${f%.fna}.tsv -source /home/team2/databases/COG2020/cog-20-db.dmnd -o o_${f%.fna}

# converting the annotated fna files to faa
  
  transeq "./o_${f%.fna}.fna" "${f%.fna}.faa" -sformat pearson

done
