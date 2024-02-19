#!/usr/bin/env python3

import argparse
import re

# crispr conversions 

# cripsr tool gives output file with a header with 5 tab-separated cols:
#       seqid, start, end, strand, pos.
# generated from nucleotide seq, so positions are amino-acid based.

'''
1. take in .faa file and crispr .tab output file
# 2. parse .faa file for seqid, sstart and sstop, strand
3. parse .tab file for seqid, start, end, strand, pos.
# 4. match .faa seqid and .tab file seqid
        convert start/stop positions
5. parse data and rearrange into a .gff format, write to a file

'''


parser = argparse.ArgumentParser()
parser.add_argument("-tab", type=str, help="input crispr output file name")
# parser.add_argument("-faa", type=str, help="input .faa file name")
parser.add_argument("-o", type=str, help="output file name")
args = parser.parse_args()

# faafile = []
tabfile = []
# faa = dict()

print('opening files...')

# with open(args.faa, 'r') as f:
#   for line in f:
#       values = line.rstrip() 
#       faafile.append(values)

with open(args.tab, 'r') as f:
    for line in f:
        values = line.rstrip()
        tabfile.append(values)

print('files opened')
print('parsing files...')
# for line in faafile:
#   if re.search(r'^>k141', line) != None:
#       seqid, sstart, sstop, strand, attributes = line.rstrip().split(' # ')
#       ID, partial, start_type, rbs_motif, rbs_spacer, gc_content = attributes.rstrip().split(';')
#       faa[seqid[1:]] = [int(sstart), int(sstop), int(strand), ID]

f = open(args.o + '.gff', 'a')
f.write('##gff-version 3\n')
for line in tabfile:
    # list all of the columns below:
    if re.search(r'^k141', line) != None:
        contig, qstart, qend, strand, pos = line.rstrip().split("\t")
        qseqid, startstop = contig.rstrip().split(':')
        start, stop = startstop.split('-')

        # sstart, sstop, sstrand, ID = faa[qseqid]
        if strand > 0:
            strand = '+'
        elif strand < 0:
            strand = '-'
        newstart = int(start) + (int(qstart)-1)
        newstop = int(start) + int(qstop)
        attributes = "."
        row = [qseqid, 'CRISPRCasTyper', 'motif', str(newstart), str(newstop), '.', str(strand), '.', attributes]
        row = '\t'.join(row)
        f.write(row + '\n')
f.close()

print('.gff file generated!')





