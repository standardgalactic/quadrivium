#!/bin/bash

# Process all .vtt files in the current directory
for input_file in *.vtt; do
    output_file="${input_file%.vtt}.txt"

    # Remove timestamps, WEBVTT headers, metadata lines, and formatting tags
    sed -E '/^WEBVTT|^[[:space:]]*$|^[0-9:\.]+ --> [0-9:\.]+|^Kind:|^Language:/d' "$input_file" | \
        sed -E 's/<[^>]+>//g' > "$output_file"

    # Remove extra blank lines
    sed -i '/^$/d' "$output_file"

    # Optional: remove leading/trailing whitespace
    sed -i 's/^ *//; s/ *$//' "$output_file"

    # Display completion message
    echo "Converted $input_file to plain text in $output_file"
done

