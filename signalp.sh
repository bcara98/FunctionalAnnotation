#!/bin/bash

# Loop through all FASTA files in the input directory. PLEASE CONFIRM AND EDIT THE LOOP INPUT TO MATCH THE DIRECTORY THAT HOLDS THE .faa FILES!!!

for file in ~/downloads/data_from_group2/*.faa
do
    # Extract the filename without the .faa extension
    filename=$(basename "$file" .faa)

    # Create a subdirectory with the same name as the input file
    mkdir -p ~/downloads/data_from_group22/"$filename"

    # Run SignalP on the input FASTA file and save output in subdirectory as GFF3 format
    signalp6 --fastafile "$file" --organism other --output_dir ~/downloads/data_from_group22/"$filename" --format txt --mode fast
done


