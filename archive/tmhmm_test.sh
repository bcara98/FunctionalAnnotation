#!/bin/bash

## TMHMM2.0 install:
# have to submit a request form on the website https://services.healthtech.dtu.dk/cgi-bin/sw_request?software=tmhmm&version=2.0c&packageversion=2.0c&platform=Linux
# downloaded on my local machine and used scp to transfer to server /home/team2/bin
# set up using installation guide along with the package

# testing:
# tmhmm /home/team2/group3/test_files/CGT2006.faa > /home/team2/group3/LT/tmhmm/tmhmm.CGT2006.out

# cpu usage
# psrecord "tmhmm /home/team2/group3/test_files/CGT2006.faa > /home/team2/group3/LT/tmhmm/tmhmm.CGT2006.out" --log tmhmm_CGT2006_test.log
# 27.18 seconds


directory="/home/team2/group3/test_files"

## easy cluster example: mmseqs easy-cluster examples/DB.fasta clusterRes tmp

for file in "$directory"/*; do
    if [ -f "$file" ]; then
        outfile=${file##*/}
        outfile=${outfile%.*}
        tmhmm $file > tmhmm_$outfile.out
    fi
done
