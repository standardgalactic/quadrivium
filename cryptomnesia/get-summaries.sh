#!/usr/bin/env bash
set -Eeuo pipefail

############################
# Configuration Variables  #
############################

CHUNK_LINES=200
MODEL_COMMAND=("ollama" "run" "vanilj/phi-4")  # Adjust this to your actual command
PROGRESS_FILE="progress.log"
SUMMARY_FILE="detailed-summary.txt"

#########################
#  Script Initialization#
#########################

main_dir="$(pwd)"
touch "$main_dir/$PROGRESS_FILE"
touch "$main_dir/$SUMMARY_FILE"

# Log function with output to console and progress file
log() {
    local message="[${USER:-$(whoami)}@$(hostname)] [$(date '+%Y-%m-%d %H:%M:%S')] $*"
    echo "$message" | tee -a "$main_dir/$PROGRESS_FILE"
}

# Check if the summarization command is available
if ! command -v "${MODEL_COMMAND[0]}" >/dev/null 2>&1; then
    echo "Error: '${MODEL_COMMAND[0]}' is not installed or not in PATH."
    exit 1
fi

# Cleanup function
cleanup_tempdirs() {
    find "$main_dir" -type d -name 'tmp_*' -exec rm -rf {} +
    log "Cleaned up all temporary directories."
}
trap cleanup_tempdirs EXIT

# Function to check if a file has been processed
is_processed() {
    grep -q "$(basename "$1") completed" "$main_dir/$PROGRESS_FILE"
}

# Mark file as processed
mark_processed() {
    echo "$(basename "$1") completed" >> "$main_dir/$PROGRESS_FILE"
}

############################
#  Processing Function     #
############################

process_files_in_directory() {
    local dir="$1"
    log "Processing directory: $dir"

    local txt_files=("$dir"/*.txt)

    for file in "${txt_files[@]}"; do
        if [[ -f "$file" && ! -L "$file" ]]; then
            if ! is_processed "$file"; then
                local file_name=$(basename "$file")
                log "Processing file: $file"
                local temp_dir=$(mktemp -d "${main_dir}/tmp_${file_name}_XXXXXX")
                local chunk_prefix="${temp_dir}/chunk"

                # Split file into chunks
                split -l "$CHUNK_LINES" "$file" "${chunk_prefix}"
                log "Split $file into chunks of $CHUNK_LINES lines each."

                # File header in the summary file
                {
                    echo "---------------"
                    echo "Summaries for file: $file_name"
                    echo "---------------"
                } >> "$main_dir/$SUMMARY_FILE"

                # Process each chunk
                local chunk_files=("${temp_dir}/chunk"*)
                for chunk_file in "${chunk_files[@]}"; do
                    if [[ -f "$chunk_file" ]]; then
                        local chunk_name=$(basename "$chunk_file")
                        log "Summarizing chunk: $chunk_name"

                        # Summarize the chunk using the model command
                        {
                            echo "Summarize the following text:"
                            cat "$chunk_file"
                            echo "---------------"
                        } | "${MODEL_COMMAND[@]}" | tee -a "$main_dir/$SUMMARY_FILE"
                    fi
                done
                
                # Cleanup after processing
                rm -rf "$temp_dir"
                log "Processed and cleaned up: $file_name"
                mark_processed "$file"
            else
                log "Skipping already processed file: $file"
            fi
        fi
    done
}

############################
#    Main Logic            #
############################

log "Script started."
process_files_in_directory "$main_dir"
log "Script completed."
