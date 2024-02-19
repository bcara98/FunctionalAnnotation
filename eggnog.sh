# time taken to run all 50 files: real	45m37.861s user	315m19.541s sys	6m44.737s

#!/bin/bash

for f in CGT****.fna; do

# annotating the files

  /home/team2/group3/AS/cog/diamond blastx --db /home/team2/databases/eggnog/bacteria.dmnd -q $f -o ${f%.fna}.tsv --outfmt 6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore qframe qseq

# generating gff and fna files

  python3 gff_from_blastX.py -blastx ${f%.fna}.tsv -source /home/team2/databases/eggnog/bacteria.dmnd -o o_${f%.fna}

# converting the annotated fna files to faa

  transeq "./o_${f%.fna}.fna" "${f%.fna}.faa" -sformat pearson

done
