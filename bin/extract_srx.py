import argparse
import csv
import re

def extract_srx_samples(input_file, output_file):
    data = []
    current_sample = None
    
    with open(input_file, 'r') as file:
        for line in file:
            sample_match = re.match(r'^\^SAMPLE = (\S+)', line)
            srx_match = re.match(r'!Sample_relation = SRA: .*?(SRX\d+)', line)
            
            if sample_match:
                current_sample = sample_match.group(1)
            elif srx_match and current_sample:
                data.append([current_sample, srx_match.group(1)])
    
    with open(output_file, 'w', newline='') as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(["Sample", "SRX"])
        writer.writerows(data)
    
    print(f"Extracted {len(data)} records and saved to {output_file}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Extract SAMPLE and SRX identifiers from file.")
    parser.add_argument("input_file", help="Path to the input file")
    parser.add_argument("output_file", help="Path to the output CSV file")
    args = parser.parse_args()
# The `extract_srx_samples(args.input_file, args.output_file)` function call is executing the
# `extract_srx_samples` function with the input file path and output file path provided as arguments.
    
    extract_srx_samples(args.input_file, args.output_file)