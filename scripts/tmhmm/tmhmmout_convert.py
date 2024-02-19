#!/usr/bin/env python3

import argparse
import re

# tmhmm conversions

# gives output file tmhmm_$file.out with five header lines followed by a single
# tab seperated line of:
#       seqID, TMHMM2.0, prediction (inside/outside), start, and stop position.
# only generated from amino acid sequence, positions are amino-acid based

'''
1. take in .faa file and tmhmm .tsv output file
2. parse .faa file for seqid, sstart and sstop, strand
3. parse .tsv file for seqid, prediction, query start/stop
4. match .faa seqid and .tsv file seqid
	convert amino acid positions into nt positions
5. parse data and rearrange into a .gff format, write to a file
6. output .bed coordinates to use with bedtools to generate
   .faa and .fna files also
'''


parser = argparse.ArgumentParser()
parser.add_argument("-tsv", type=str, help="input tmhmm output file name")
parser.add_argument("-faa", type=str, help="input .faa file name")
parser.add_argument("-o", type=str, help="output file name")
args = parser.parse_args()

faafile = []
tsvfile = []
faa = dict()

print('opening files...')

with open(args.faa, 'r') as f:
	for line in f:
		values = line.rstrip() 
		faafile.append(values)

with open(args.tsv, 'r') as f:
	for line in f:
		values = line.rstrip()
		tsvfile.append(values)

print('files opened')
print('parsing files...')
for line in faafile:
	if re.search(r'^>k141', line) != None:
		seqid, sstart, sstop, strand, attributes = line.rstrip().split(' # ')
		ID, partial, start_type, rbs_motif, rbs_spacer, gc_content = attributes.rstrip().split(';')
		faa[seqid[1:]] = [int(sstart), int(sstop), int(strand), ID]

f = open(args.o + '.gff', 'a')
f.write('##gff-version 3\n')
for line in tsvfile:
	# list all of the columns below:
	if re.search(r'^#', line) == None:
		qseqid, tmhmm2, prediction, qstart, qstop = line.rstrip().split()
		sstart, sstop, strand, ID = faa[qseqid]
		qstart = (int(qstart)-1)*3
		qstop = int(qstop)*3
		if int(qstart) < int(qstop):
			strand = '+'
			newstart = sstart + qstart
			newstop = sstart + qstop
		else:
			strand = '-'
			newstop = sstart + qstop
			newstart = sstart + qstart
		attributes = "Name=" + prediction
		row = [qseqid, tmhmm2, 'motif', str(newstart), str(newstop), '.', str(strand), '.', attributes]
		row = '\t'.join(row)
		f.write(row + '\n')
f.close()

print('.gff file generated!')





