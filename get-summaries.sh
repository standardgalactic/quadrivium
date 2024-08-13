#!/bin/bash

# Define global summary file and supersummary file
global_summary_file="overview.txt"
supersummary_file="supersummary.txt"

# Create or clear the global summary file and supersummary file
echo "Global Processing Summary" > "$global_summary_file"
echo "========================" >> "$global_summary_file"
echo "Supersummary of Overviews" > "$supersummary_file"
echo "========================" >> "$supersummary_file"

# Function to check if a file is already processed
is_processed() {
    grep -Fxq "$1" "$main_dir/$progress_file"
}

# Function to process files in a specific directory, excluding overview.txt initially
process_files_in_dir() {
    local dir=$1
    local progress_file="$dir/progress.log"
    local overview_file="$dir/overview.txt"

    # Create progress file if it doesn't exist
    touch "$progress_file"

    # Initialize or clear the overview file
    echo "Processing Overview for $dir" > "$overview_file"
    echo "============================" >> "$overview_file"

    # Iterate over each .txt file in the specified directory except overview.txt
    for file in "$dir"/*.txt; do
        if [ "$file" != "$overview_file" ]; then
            if [ -f "$file" ]; then
                local file_path=$(pwd)/"$file"
                if ! is_processed "$file_path"; then
                    echo "Checking $file"
                    echo "Checking $file" >> "$overview_file"

                    # Replace `ollama run wizardlm2` with your actual processing command
                    ollama run wizardlm2 "Summarize:" < "$file" | tee -a "$overview_file"

                    echo "$file_path" >> "$progress_file"
                fi
            fi
        fi
    done

    # Summarize the overview file itself and append to supersummary
    echo "Summary for $dir:" >> "$supersummary_file"
    ollama run wizardlm2 "Summarize:" < "$overview_file" | tee -a "$supersummary_file"
    echo "========================" >> "$supersummary_file"
}

# Get the current directory
main_dir=$(pwd)

# Iterate over each subdirectory in the current directory
for dir in */; do
    # Remove trailing slash from directory name
    dir=${dir%/}

    # Check if it's a directory
    if [ -d "$dir" ]; then
        echo "Processing directory: $dir"

        # Process files in the current subdirectory
        process_files_in_dir "$dir"
    fi
done

echo "Processing complete. Check $supersummary_file for global summary."
