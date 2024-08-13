#!/bin/bash

# Iterate over all txt files in the current directory
for file in *.txt; do
	    # Calculate the number of lines per split part
	        total_lines=$(wc -l <"$file")
		    ((lines_per_part = (total_lines + 9) / 10))  # This ensures that you round up

		        # Split the file
			    # -d: Use numeric suffixes
			        # -l: Specify the number of lines per split
				    split -d -l "$lines_per_part" "$file" "${file%.txt}_part_"
			    done

