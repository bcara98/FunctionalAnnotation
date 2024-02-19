#!/usr/bin/env python3

import argparse
import re

'''
take in .faa and .res.blast file

.faa format:
>seqid # sstart # sstop # strand
AASEQUENCE

.res.blast format (blast-like with added cols 13-14 with qframe and seq):
qseqid	sseqid	pident	length	mismatch	gapopen	qstart	qend	sstart	send	evalue	bitscore	qframe	SEQ


to do:
1. take in .faa and .res.blast files
2. parse .faa file for seqid, sstart and sstop, strand
3. parse .blast-like format for seqid
		compute qstart, qend, and length from aa to nt (qstart-1 * 3, qend * 3, length * 3)
		check that calculated stop - start = calculated length
4. match .faa and .blast seqid
		calculate new start/stop values
		.faa sstart + (qstart-1 * 3) = new start
		new start + length = new stop
		check
5. parse rest of data required for .gff file output
		source, feature (sseqid from .blast), score (bitscore from .blast), strand (from .faa), frame (from .blast), attribute (pident, mismatch, gapopen, evalue)
'''


parser = argparse.ArgumentParser()
parser.add_argument("-faa", type=str, help="input .faa file name")
parser.add_argument("-blast", type=str, help="input .blast-like file name")
parser.add_argument("-source", type=str, help="input source of annotations, ex. database name")
parser.add_argument("-o", type=str, help="output file name")
args = parser.parse_args()


faafile = []
blastfile = []
faa = dict()
seqtype = ''
filetype = ''
print('opening files...')
with open(args.faa, 'r') as f:
    for line in f:
        values = line.rstrip() 
        faafile.append(values)

with open(args.blast, 'r') as f:
	for line in f:
		values = line.rstrip()
		blastfile.append(values)

print('files opened')
print('parsing files...')
for line in faafile:
	if re.search(r'^>k141', line) != None:
		seqid, sstart, sstop, strand, attributes = line.rstrip().split(' # ')
		ID, partial, start_type, rbs_motif, rbs_spacer, gc_content = attributes.rstrip().split(';')
		faa[seqid[1:]] = [int(sstart), int(sstop), int(strand), ID]

f = open(args.o + '.gff', 'a')
f.write('##gff-version 3\n')
print('extracting info from files...')
for line in blastfile:
	# list all of the columns below:
	qseqid, sseqid, pident, length, mismatch, gapopen, qstart, qend, sstartx, sendx, evalue, bitscore, qframe, SEQ = line.rstrip().split("\t")
	sstart, sstop, strand, ID = faa[qseqid]
	if strand > 0:
		strand = '+'
	elif strand < 0:
		strand = '-'
	qstart = (int(qstart)-1)*3
	qend = int(qend)*3
	length = int(length)*3
	if (qend - qstart) == length:
		newstart = int(sstart) + qstart
		newstop = newstart + length
	# attributes = 'pident=' + pident + ';mismatch=' + mismatch + ';gapopen=' + gapopen + ';evalue=' + evalue
	# attributes = "Parent=" + ID[3:] + ";Dbxref=UnirefKB:" + str(sseqid) + ";Note= pident:" + pident + ", mismatch:" + mismatch + ', gapopen:' + gapopen + ', evalue:' + evalue
	attributes = "Dbxref=UnirefKB:" + str(sseqid) + ";Note= pident:" + pident + ", mismatch:" + mismatch + ', gapopen:' + gapopen + ', evalue:' + evalue
	row = [qseqid, args.source, 'translated_nucleotide_match', str(newstart), str(newstop), str(bitscore), str(strand), str(qframe), attributes]
	row = '\t'.join(row)
	f.write(row + '\n')

f.close()

print('.gff file generated!')


