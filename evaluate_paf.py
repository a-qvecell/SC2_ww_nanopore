### This script is part of the pipeline used for analysis of SARS-CoV-2 in wastewater at Statens Serum Institut, Denmark. 
### It is written by Amanda Gammelby Qvesel (amqv@ssi.dk).
### It takes a .paf file ($1) and a fasta reference file with sequences of VOCs/VOIs ($2) as input.
### It counts the number of reads mapping to each reference in the sequence area of interest.
### It writes the result to an output file.

import sys, pafpy, os
path = sys.argv[1]
ref = sys.argv[2]
barcode = path.split("_")[-1].split(".")[0] #input file format: mapped_filtered_trimmed_barcode"$i".paf, $i denotes the barcode index (01 to 96)

count_dict = dict()

# go through reference file and create count dict with 0 as starting value for each VOC/VOI
for line in open(ref, "r"):
    if line.startswith(">"):
        variant = line[1:-1]
	count_dict[variant] = 0

# go through file with mapping information. Count primary mappings in the correct area:
with pafpy.PafFile(path) as paf:
    for record in paf:
        if record.is_primary() and record.qstart < 110 and record.qend > 820:
	    count_dict[record.tname] += 1

# write results
outfile = open(barcode+"_mapping.csv", "w")

for variant in count_dict.keys():
    print(barcode, variant, count_dict[variant], sep = ",", file = outfile)
outfile.close()

