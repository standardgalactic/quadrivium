#!/bin/bash

# Iterate over all txt files in the current directory
for file in *.txt; do
	    # Calculate the number of lines per split part
	        total_lines=$(wc -l <"$file")
		    ((lines_per_part = (total_lines + 24) / 25))  # This ensures that you round up to ensure all content is included

		        # Split the file
			    # -d: Use numeric suffixes
			        # -l: Specify the number of lines per split
				    split -d -l "$lines_per_part" "$file" "${file%.txt}_part_"
			    done

