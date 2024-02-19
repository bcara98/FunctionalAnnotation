# time taken to run all 50 files: real	0m35.632s user	1m27.578s sys	0m4.022s

#!/bin/bash

for f in CGT****.fna; do

# annotating the files

  /home/team2/group3/AS/cog/diamond blastx --db card.dmnd -q $f -o ${f%.fna}.tsv --outfmt 6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore qframe qseq

# generating gff and fna files

  python3 gff_from_blastX.py -blastx ${f%.fna}.tsv -source card.dmnd -o o_${f%.fna}

# converting the annotated fna files to faa

  transeq "./o_${f%.fna}.fna" "${f%.fna}.faa" -sformat pearson

done
