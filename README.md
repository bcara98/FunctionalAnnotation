# Team2-FunctionalAnnotation

## Clustering

The first step is to cluster the sequences using DIAMOND.

Diamond installation with conda:
1. First set up a new conda environment:
    * `conda create -n diamond`
2. Then install diamond with conda, as well as seqkit.
    * `conda install -c bioconda diamond`
    * `conda install -c bioconda seqkit`

The basic command line to run diamond is:
`diamond cluster -d $file -o ./$outfile.cluster.tsv --approx-id 50 -M 64G --header`
 
* `-d`: input database
* `-o`: output file
* `--approx-id`: percent sequence identity
* `-M`: memory usage
* `--header`: includes a header line in the output .tsv file

To run on all 50 files: `cluster_dmnd.sh`
* The shell script `cluster_dmnd.sh` loops through a directory of .faa files.
* It clusters the sequences with diamond and outputs a .tsv file for each, then removes duplicates to leave only unique IDs
* Uses seqkit to generate a file with only the clustered .faa files. 

To generate the .fna files, use `cluster_faa2fna.sh` to convert the .faa files.
* It generates a .bed-like file from the .faa file, then uses `seqkit grep` to grab the .fna files from /home/team2/group3/fna_gff_group2/fna


## OMPdb

OMPdb was downloaded from http://www.ompdb.org/OMPdb_down/current/OMPdb.fasta.gz using `wget`.
* OMPdb location on webserver: /home/team2/databases/OMPdb/OMPdb.fasta.gz


First, `gunzip` the OMPdb.fasta.gz, then make it a diamond database:

- `conda activate diamond`
- `diamond makedb --in /home/team2/databases/OMPdb/OMPdb.fasta -d OMPdb`
    -  creating a diamond-formatted database file: `diamond makedb --in reference.fasta -d reference`

Then run the script, `ompdb_blastx.sh`
* Performs a nucleotide blast against the protein database with the clustered .fna sequences. It outputs a BLAST tabular output with 12 columns with the addition of 2 extra columns, 13-qframe and 14-qseq. 

* example blastx command: `diamond blastx --iterate --top 10 -d reference -q queries.fasta -o matches.tsv -f <output format>`

To convert the blast output into a .gff, run the script `ompdb_wrapper.sh -o <output directory>`. 
* `-o`: directory path where output files will be placed.
* This wrapper script loops through the generated .blast files and runs `gff_from_blastx.py` to convert the files. 
* Outputs:
    * <file>.cluster.ompdb.gff
    * <file>.cluster.ompdb.fna files.


Finally, to generate .fna files, use the emboss tool, transeq.

* `conda activate emboss`
* `for file in <.fna directory>/*.fna; do transeq <output .faa directory>/$file ${file%.*}.faa -sformat pearson; done`


## TMHMM2.0

TMHMM2.0 installation:
* To install, you have to submit a request form on the [website](https://services.healthtech.dtu.dk/cgi-bin/sw_request?software=tmhmm&version=2.0c&packageversion=2.0c&platform=Linux)
* Download locally and then use `scp` to transfer to server in `/home/team2/bin`
* Set up using installation guide along with the package:
    * requires perl dependency, and must be placed in the $PATH.
* Basic usage: `tmhmm input.faa > output.out`


Once installed, run  `./tmhmm_run.sh`.
* Basic shell script which loops through `/home/team2/group3/clust_data_group2/faa`
* Output file: tmhmm_$file.out
    * tab seperated line of: seqID, TMHMM2.0, prediction (inside/outside/transmembrane), start, and stop position.


Afterwards, run `tmhmm_wrapper.sh -o <output path>`
* `-o`: output .gff file location
* Wrapper script for `tmhmmout_convert.py` which converts TMHMM2.0 output to .gff format.

The next script uses bedtools: `conda activate bedtools`
   
Then run `tmhmm_gff2fna.sh -o <outdir> -gff <path-to-gff>` to get nucleotide sequences. 
* `-o`: output .fna file location
* `-gff`: path to .gff files generated from `tmhmm_wrapper.sh`
* uses `bedtools getfasta`

Finally, to generate .fna files, use the emboss tool, transeq.

* `conda activate emboss`
* `for file in <path-to-.fna>/*.fna; do transeq <output-.faa-directory>/$file ${file%.*}.faa -sformat pearson; done`



 ## SignalP6.0
This guide explains how to download and install SignalP6.0, a program used to predict the presence and location of signal peptide cleavage sites in amino acid sequences.

### Installation
Download SignalP6.0 from this link: https://services.healthtech.dtu.dk/services/SignalP-6.0/
Choose the specific program for your system (e.g., MacOS). Download the fast mode.

`gunzip` the directory and activate a conda environment using the following command:
Copy code
* `conda activate signal`

Install the program by running the following command in the unzipped directory:

* `pip install signalp-6-package/`

Copy the model files over by running the following command in the same directory:

* `SIGNALP_DIR=$(python3 -c "import signalp; import os; print(os.path.dirname(signalp.__file__))" )
cp -r signalp-6-package/models/* $SIGNALP_DIR/model_weights/`

To run SignalP6.0 on a set of .faa files, use the `signalp.sh` script. This script runs SignalP6.0 fast mode for all of the 50 .faa files in the directory.

After SignalP6.0 runs, it outputs a directory for each sample that contains prediction.text, output.gff3, region_output.gff3, and processed_entries.fasta files. To pull the output.gff3 files from each directory and compile them into a folder, use the `signalp_output.sh` script.

### Formatting
Note that the output .gff3 file from SignalP6.0 may not pass the GFF3 Validator due to spacing issues in the header. To remove the space and format the .gff3 correctly, run `formatgff3.sh`.

## CARD

CARD was downloaded from https://card.mcmaster.ca/download/0/broadstreet-v3.2.6.tar.bz2 using `wget`.
* CARD location on webserver: /home/team2/databases/card


First, open the file using the following command: `tar -xvf broadstreet-v3.2.6.tar.bz2`

- `conda activate diamond`
- `diamond makedb --in /home/team2/databases/cardprotein_fasta_protein_homolog_model.fasta -d card.dmnd`
    -  creating a diamond-formatted database file: `diamond makedb --in reference.fasta -d reference`

`conda activate emboss` to run the script (the script uses this environment to convert annotated fna to faa sequences
Then run the script, `card.sh`
* Performs a nucleotide blast against the protein database with the clustered .fna sequences. It outputs a BLAST tabular output with 12 columns with the addition of 2 extra columns, 13-qframe and 14-qseq.
* Annotates the files using the following command: `diamond blastx --db card.dmnd -q $f -o ${f%.fna}.tsv --outfmt 6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore qframe qseq`
* Generates gff and fna files using the following command: `python3 gff_from_blastX.py -blastx ${f%.fna}.tsv -source card.dmnd -o o_${f%.fna}`
* And converts the annotated .fna files to .faa (protein sequences) using the following command: `transeq "./o_${f%.fna}.fna" "${f%.fna}.faa" -sformat pearson`
* Outputs:
    * o_<file name>.gff
    * o_<file name>.fna 
    * and <file name>.faa 

## COG

COG was downloaded from ftp://ftp.ncbi.nlm.nih.gov/pub/COG/COG2020/data/ using `wget`.
* COG location on webserver: /home/team2/databases/COG2020


This installs the COG database in the diamond format directly (cog-20-db.dmnd).

`conda activate emboss` to run the script (the script uses this environment to convert annotated fna to faa sequences.
Then run the script, cog.sh
* Performs a nucleotide blast against the protein database with the clustered .fna sequences. It outputs a BLAST tabular output with 12 columns with the addition of 2 extra columns, 13-qframe and 14-qseq.
* Annotates the files using the following command: `diamond blastx --db /home/team2/databases/COG2020/cog-20-db.dmnd -q $f -o ${f%.fna}.tsv --outfmt 6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore qframe qseq
`
* Generates gff and fna files using the following command: `python3 gff_from_blastX.py -blastx ${f%.fna}.tsv -source /home/team2/databases/COG2020/cog-20-db.dmnd -o o_${f%.fna}`
* And converts the annotated .fna files to .faa (protein sequences) using the following command: `transeq "./o_${f%.fna}.fna" "${f%.fna}.faa" -sformat pearson`
* Outputs:
    * <file name>.gff
    * o_<file name>.fna 
    * and <file name>.faa 
   
   ## EGGNOG

EGGNOG installation via conda: `conda install -c bioconda eggnog-mapper`.
* EGGNOG location on webserver: /home/team2/databases/eggnog

`download_eggnog_data.py -P` downloads the eggNOG-mapper and PFAM databases.

`conda activate emboss` to run the script (the script uses this environment to convert annotated fna to faa sequences.
Then run the script, eggnog.sh
* Performs a nucleotide blast against the protein database with the clustered .fna sequences. It outputs a BLAST tabular output with 12 columns with the addition of 2 extra columns, 13-qframe and 14-qseq.
* Annotates the files using the following command: `diamond blastx --db /home/team2/databases/eggnog/bacteria.dmnd -q $f -o ${f%.fna}.tsv --outfmt 6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore qframe qseq
`
* Generates gff and fna files using the following command: `python3 gff_from_blastX.py -blastx ${f%.fna}.tsv -source /home/team2/databases/eggnog/bacteria.dmnd -o o_${f%.fna}`
* And converts the annotated .fna files to .faa (protein sequences) using the following command: `transeq "./o_${f%.fna}.fna" "${f%.fna}.faa" -sformat pearson`
* Outputs:
    * o_<file name>.gff
    * o_<file name>.fna 
    * and <file name>.faa 
   
## Virulence Factor

1. Set up conda environment<br />

 The packages to be installed are *mmseqs2* and *emboss*. <br />
  *If you have those tools installed somewhere, you can skip this step* <br />

  -  `conda create -n virulence -y`<br />
  -  `conda activate virulence` <br />
  - `conda install -c conda-forge -c bioconda mmseqs2` <br />
  - `conda install -c bioconda emboss` <br />


2. Download **VFDB** database<br />
  - `wget http://www.mgc.ac.cn/VFs/Down/VFDB_setA_pro.fas.gz `<br />


4. Running **virulence_mmseqs.sh**<br /> 

  This wrapper script perfroms MMseqs2 BLASTx in most sensitive mode. Then the result (BLAST fmt) is converted to gff using mmseqs_gff_from_blastX.py. The result is also converted to fna by running mmseqs_blastx2fna.py. Finally the fna is translated to faa using transeq from emboss.By running the wrapper virulence_mmseqs.sh, the three steps will be done automatically and sequentially.<br />
   - Usage`./virulence_mmseqs.sh -d <protein database file -f <sample fna dir> -w <integer 1 or 0>`<br />
   - For example: 
   
   ``` 
   bash virulence_mmseqs.sh -d /home/team2/databases/VFDB/VFDB_setA_pro.fas.gz -f /home/team2/group3/fna_gff_group2/fna -w 1
   
   Alternatively:
   ./virulence_mmseqs.sh -d /home/team2/databases/VFDB/VFDB_setA_pro.fas.gz -f /home/team2/group3/fna_gff_group2/fna -w 1
   ```

5. Output files<br />
  - result/VFDB/gff/ : contains all files in gff format
  - result/VFDB/fna/ : contains all files in fna format
  - result/VFDB/faa/ : contains all files in faa format

6. Deactivate conda environment<br />
  - `conda deactivate`

## Prophage

1. Set up conda environment<br />

 The packages to be installed are *mmseqs2* and *emboss*. <br />
  *If you have those tools installed somewhere, you can skip this step* <br />

  - `conda create -n prophage -y`<br />
  - `conda activate prophage` <br />
  - `conda install -c conda-forge -c bioconda mmseqs2` <br />
  - `conda install -c bioconda emboss` <br />


2. Download **PHROGs** database<br />
  - `wget https://phrogs.lmge.uca.fr/downloads_from_website/FAA_phrog.tar.gz`<br />


4. Running **prophage_mmseqs.sh**<br /> 

  This wrapper script perfroms MMseqs2 BLASTx in most sensitive mode. Then the result (BLAST fmt) is converted to gff using mmseqs_gff_from_blastX.py. The result is also converted to fna by running mmseqs_blastx2fna.py. Finally the fna is translated to faa using transeq from emboss. By running the wrapper prophage_mmseqs.sh, the three steps will be done automatically and sequentially.<br />
   - Usage `sh prophage_mmseqs.sh -d <protein database file> -f <sample fna dir>` <br />
   - For example:
   
   ```
    sh prophage_mmseqs.sh -d home/team2/databases/phrogs/FAA_phrog.tar.gz -f /home/team2/group3/fna_gff_group2/fna
   ```
 5. Output files<br />
  - result/gff/ : contains all files in gff format
  - result/fna/ : contains all files in fna format
  - result/faa/ : contains all files in faa format

6. Deactivate conda environment<br />
 - `conda deactivate`
   
## Plasmids

1. Set up conda environment<br />

 The packages to be installed are *mmseqs2* and *emboss*. <br />
  *If you have those tools installed somewhere, you can skip this step* <br />

  - `conda create -n plasmid -y`<br />
  - `conda activate plasmid` <br />
  - `conda install -c conda-forge -c bioconda mmseqs2` <br />
  - `conda install -c bioconda emboss` <br />


2. Download **PLSDB** database<br />
  - `wget https://ccb-microbe.cs.uni-saarland.de/plsdb/plasmids/download/plsdb.fna.bz2`<br />
  - `bzip2 -d plsdb.fna.bz2`<br />


4. Running **plasmids_mmseqs2.sh**<br /> 

  This wrapper script perfroms MMseqs2 BLASTn in most sensitive mode. Then the result (BLAST fmt) is converted to gff using mmseqs_gff_from_blastn.py. The result is also converted to fna by running mmseqs_blastn2fna.py. Finally the fna is translated to faa using transeq from emboss. By running the wrapper plasmids_mmseqs2.sh, the three steps will be done automatically and sequentially.<br />
   - Usage `sh plasmids_mmseqs2.sh -d <plasmid database file> -f <sample fna dir>` <br />
   - For example:
   
   ```
    sh plasmids_mmseqs2.sh -d /home/team2/databases/plsdb/plsdb.fna -f /home/team2/group3/fna_gff_group2/fna
   ```
 5. Output files<br />
  - result/gff/ : contains all files in gff format
  - result/fna/ : contains all files in fna format
  - result/faa/ : contains all files in faa format

6. Deactivate conda environment<br />
 - `conda deactivate`

## Merging gff files

1. Set up conda environment<br />
The requirements are python3 with pandas installed. If you've already have this python package, you may skip this step.

  - `conda create -n merge_gff -y`<br />
  - `conda activate merge_gff`<br />
  - `pip install pandas`<br />

2. Running the merge_gff.py
  - `python3 merge_gff.py -g1 <gff file> -g2 <gff file> -o <merged gff file name>`<br />
  - For example: 
   ```
   python3 merge_gff.py -g1 1.gff -g2 2.gff -o merged.gff
   ```
  
3. Output file<br />
  The output file would be a merged gff file and stored in the working directory. The name of the output is specified by the o flage.



## Merging .faa files

Script to merge files. Assumes that all outputs are in all_results directory, with a directory for each tool, with a faa folder.

`conda activate diamond` to use seqkit
   
`merge_faa.sh`
 
## Merging .fna files

Script to merge files. Assumes that all outputs are in all_results directory, with a directory for each tool, with a faa folder.

`conda activate diamond` to use seqkit
   
`merge_fna.sh`


