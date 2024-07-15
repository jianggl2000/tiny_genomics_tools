#!/usr/bin/env python

import sys
import gzip

def process_vcf(input_file, output_file):
    with gzip.open(input_file, 'rt') as infile, open(output_file, 'w') as outfile:
        for line in infile:
            if line.startswith('##'):
                continue
            elif line.startswith('#CHROM'):
                outfile.write(line)
            else:
                fields = line.strip().split('\t')
                format_field = fields[8]
                ds_index = format_field.split(':').index('DS')

                new_fields = fields[:9]
                for sample in fields[9:]:
                    ds_value = sample.split(':')[ds_index]
                    new_fields.append(ds_value)

                outfile.write('\t'.join(new_fields) + '\n')

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python script.py input.vcf.gz output.txt")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2]
    process_vcf(input_file, output_file)
