#!/bin/bash
#This script removes the spacing betweent gff-version in the header in order to be recognized as a gff3 file during the merging process
for file in *.gff3; do
    sed 's/## gff-version/##gff-version/' "$file" > "${file%.gff3}.gff"
done
