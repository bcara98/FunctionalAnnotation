#!/usr/bin/env python3

import argparse
import re

'''
take in a blast-like file to generate a .gff

.res.blast format (blast-like with added cols 13-14 with qframe and seq):
qseqid	sseqid	pident	length	mismatch	gapopen	qstart	qend	sstart	send	evalue	bitscore	qframe	qseq


to do:
1. take in .res.blast files
2. parse .faa file for seqid, sstart and sstop
3. parse .blast-like format for seqid
4. compute start/stop values
5. parse rest of data required for .gff file output
		source, feature (SequenceOntology format), score (bitscore from .blast), strand (from .faa), frame (from .blast), attribute (Dbxref, pident, mismatch, gapopen, evalue)
		
'''


parser = argparse.ArgumentParser()
parser.add_argument("-blastx", type=str, help="input .blast-like file name (nt sequence)")
parser.add_argument("-source", type=str, help="input source of annotations, ex. database name")
parser.add_argument("-o", type=str, help="output file name")
args = parser.parse_args()


blastxfile = []
faa = dict()
print('opening files...')
with open(args.blastx, 'r') as f:
	for line in f:
		values = line.rstrip()
		blastxfile.append(values)


f = open(args.o + '.gff', 'a')
g = open(args.o + '.fna', 'a')
f.write('##gff-version 3\n')
print('extracting info from files...')
for line in blastxfile:
	qseqid, sseqid, pident, length, mismatch, gapopen, qstart, qend, sstartx, sendx, evalue, bitscore, qframe, SEQ = line.rstrip().split("\t")
	seqid, startstop = qseqid.rstrip().split(':')
	start, stop = startstop.rstrip().split('-')
	if int(qstart) < int(qend):
		strand = '+'
		newstart = int(start) + (int(qstart)-1)
		newstop = int(start) + int(qend)
	else:
		strand = '-'
		newstart = int(start) + (int(qend)-1)
		newstop = int(start) + int(qstart) 

	attributes = "Dbxref=UnirefKB:" + str(sseqid) + ";Note= pident:" + pident + ", mismatch:" + mismatch + ', gapopen:' + gapopen + ', evalue:' + evalue
	row = [qseqid, args.source, 'nucleotide_to_protein_match', str(newstart), str(newstop), str(bitscore), str(strand), str(abs(qframe)), attributes]
	row = '\t'.join(row)
	f.write(row + '\n')

	g.write('>' + seqid + ':' + str(newstart) + '-' + str(newstop) + '; Db:' + args.source + '; UnirefKB:' + sseqid + '\n')
	g.write(SEQ + '\n')


f.close()
g.close()



print('.gff file generated!')


