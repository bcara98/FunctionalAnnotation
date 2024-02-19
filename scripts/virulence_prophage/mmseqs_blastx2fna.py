#!/usr/bin/env python3
import argparse

#parsing the argument
parser = argparse.ArgumentParser()
parser.add_argument('--blast', action='store', type=str, required=True, help='mmseqs blastx fmt6 with qframe and qseq')
parser.add_argument('--out', action='store', type=str, required=True, help='output file name')
args = parser.parse_args()


blast_fh = open(args.blast, 'r') #open blast output
out_fh = open(args.out, 'w') #open output file

with open(args.blast, 'r') as blast_fh:
    for line in blast_fh:
        header = line.rstrip().split('\t')[0]

        anno = line.rstrip().split('\t')[1]
        seq = line.rstrip().split('\t')[13]
        #start and stop in the header
        start = int(header.split(':')[1].split('-')[0])
        stop = int(header.split(':')[1].split('-')[1])

        #get the start and end from blast output
        blast_start = int(line.rstrip().split('\t')[6])
        blast_end = int(line.rstrip().split('\t')[7])

        
        #calculate the new start and end
        if (blast_end < blast_start):
            new_start = start + blast_end - 1
            new_end = stop + blast_start - 1
            new_seq = seq [blast_end-1:blast_start-1+1]
        else:
            new_start = start + blast_start - 1
            new_end = stop + blast_end - 1
            new_seq = seq [blast_start-1:blast_end-1+1]

        #genreate new sequence based on the indexing

        new_header = header.rsplit(':')[0]



        #write the output in annotated fasta file format
        print(f'>{new_header}:{new_start}-{new_end} # {anno}', file=out_fh)
        print(new_seq,file=out_fh)

print("Successfully convert blastx output to annotated fna!")