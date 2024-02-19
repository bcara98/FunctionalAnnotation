#!/bin/bash

# concatenating fna files.

samples="CGT2006 CGT2010 CGT2044 CGT2049 CGT2060 CGT2069 CGT2076 CGT2093 CGT2114 CGT2116 CGT2119 CGT2123 CGT2135 CGT2196 CGT2214 CGT2269 CGT2278 CGT2287 CGT2304 CGT2318 CGT2326 CGT2332 CGT2344 CGT2364 CGT2374 CGT2386 CGT2393 CGT2400 CGT2424 CGT2427 CGT2428 CGT2443 CGT2471 CGT2472 CGT2514 CGT2517 CGT2540 CGT2552 CGT2567 CGT2599 CGT2628 CGT2659 CGT2683 CGT2742 CGT2785 CGT2805 CGT2843 CGT2858 CGT2878 CGT2908"

results="/home/team2/group3/all_results"

for file in $samples; do
	cat $results/cog/fna/o_$file.fna $results/eggnog/fna/o_$file.fna $results/ompdb/fna/$file.cluster.ompdb.fna  $results/plasmids/fna/$file.fna   $results/prophage/fna/$file.fna  $results/tmhmm/fna/$file.cluster.tmhmm.fna   $results/virulence/fna/$file.fna >> $results/merged/fna/$file.merged.fna
	echo "merging sample: $file"

	seqkit rename -n $results/merged/fna/$file.merged.fna > $results/merged/fna/$file.rename.fna
	seqkit sort -n $results/merged/fna/$file.rename.fna > $results/merged/fna/$file.annotated.fna
done

rm *.rename.fna
rm *.merged.fna