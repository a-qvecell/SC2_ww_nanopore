#!/bin/bash
### This pipeline was developed by Amanda Gammelby Qvesel (amqv@ssi.dk) from Statens Serum Institut, Denmark in 2022 
### as part of the national analysis of SARS-CoV-2 in wastewater.
### The script performs processing and analysis of wastewater SARS-CoV-2 Nanopore reads. 
### The region amplified for analysis spans the nucleotides 22799-23847, corresponding to amino acids 413-761 of the SARS-CoV-2 spike protein.

### The files analysed in this script are the fastq_pass files from the sequencing machine for each barcode (barcode index given as argument $1, i.e. from 01 to 96).
### The $ref argument refers to the reference fasta file (containing VOI/VOC sequences) in use at the given point in time.

### The analysed data (raw reads excluding reads mapping to the human genome) can be found in the ENA database under the BioProject identifier PRJEB72806.


# run cutadapt
cutadapt -q 13,13 -o barcode"$1"/trimmed_barcode"$1".fastq.gz barcode"$1"/all_barcode"$1".fastq.gz;


# run nanofilt
gzip -dc barcode"$1"/trimmed_barcode"$1".fastq.gz | NanoFilt -l 900 --maxlength 1200 | gzip > barcode"$1"/filtered_trimmed_barcode"$1".fastq.gz ;
# count reads; if sufficient, run minimap2 and analyse mapping results using separate python script
rc=$(gzip -dc barcode"$1"/filtered_trimmed_barcode"$1".fastq.gz | grep -c 'runid')

if (( $rc >= 1000 )); then \
minimap2 -x map-ont -c $ref barcode"$1"/filtered_trimmed_barcode"$1".fastq.gz > barcode"$1"/mapped_filtered_trimmed_barcode"$1".paf;
python3 evaluate_paf.py barcode"$1"/mapped_filtered_trimmed_barcode"$1".paf $ref ;

fi

