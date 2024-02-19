#!/bin/bash

# Set input and output directories
input_dir="Location/of/your/files"
output_dir="Desired/output/location/of/the/output.gff3/files"

# Create the output directory if it does not exist
mkdir -p "$output_dir"

# Loop through each subdirectory in the input directory
for sub_dir in "$input_dir"/*; do
  # Check if the current item is a directory
  if [ -d "$sub_dir" ]; then
    # Set the output file name based on the subdirectory name
    output_file="$output_dir/$(basename "$sub_dir").gff3"
    
    # Renaming the file to the respective folder:
    cp "$sub_dir/output.gff3" "$output_file"
  fi
done

