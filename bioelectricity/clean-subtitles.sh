#!/bin/bash

# Loop through all files passed as arguments
for fname in "$@"; do
    output_fname="${fname%.vtt}.txt"

    # Process the VTT file to extract text
    sed 's/\r$//' "$fname" |                         # Remove carriage returns
    awk 'BEGIN {RS=""; FS="\n"} {                    # Set record separator to blank line, field separator to newline
        for (i=3; i<=NF; i++) {                      # Skip the first two lines (number and timestamp)
            if ($i !~ /^$/ && $i !~ /-->/ && $i !~ /^(Kind:|Language:)/) {         # Check line is not empty, not a timestamp, and not metadata
                gsub(/<[^>]*>/, "", $i);             # Remove all HTML-like tags
                gsub(/\[.*\]/, "", $i);              # Optional: Remove brackets if they contain metadata
                if ($i !~ /^ *$/) {                  # Ensure the line is not just empty spaces
                    print $i;                        # Print line, each on new line
                }
            }
        }
    }' |                                            # End awk script
    sed 's/\\/\\\\/g; s/"/\\"/g' |                  # Escape backslashes and double quotes for JSON
    tr -d '\t' > "$output_fname"                    # Remove tabs and write to file
    echo "Processed $fname into $output_fname"
done
