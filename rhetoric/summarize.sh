#!/bin/bash

# Script to process text files (excluding overview.txt) and generate summaries
# Usage: Place in directory with .txt files and run

# Constants
readonly MAIN_DIR="$(pwd)"
readonly PROGRESS_FILE="$MAIN_DIR/progress.log"
readonly PROCESSED_FILES="$MAIN_DIR/processed_files.log"
readonly SUMMARY_FILE="$MAIN_DIR/detailed_summary.txt"
readonly CHUNK_LINES=100
readonly OLLAMA_MODEL="vanilj/phi-4"

# Check if file was already processed
is_processed() {
    grep -Fxq "$1" "$PROCESSED_FILES" 2>/dev/null
}

# Logging helper
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$PROGRESS_FILE"
}

# Initialize logs
initialize_logs() {
    for log_file in "$PROGRESS_FILE" "$PROCESSED_FILES" "$SUMMARY_FILE"; do
        touch "$log_file" || {
            echo "Cannot create $log_file in $MAIN_DIR" >&2
            exit 1
        }
    done
}

# Summarize a chunk
summarize_chunk() {
    local chunk_path="$1"
    local filename="$2"
    local chunkname="$(basename "$chunk_path")"

    log "Summarizing $chunkname"

    {
        echo -e "\n===== Summary of $filename (chunk: $chunkname) =====\n"
        ollama run "$OLLAMA_MODEL" "Summarize:" < "$chunk_path"
        echo -e "\n---\n"
    } | tee -a "$SUMMARY_FILE"
}

# Process individual file
process_file() {
    local file="$1"
    local filename="$(basename "$file")"

    log "Processing file: $filename"

    local temp_dir="$(mktemp -d)"
    trap 'rm -rf "$temp_dir"' RETURN

    split -l "$CHUNK_LINES" -d --additional-suffix=".txt" "$file" "$temp_dir/${filename}_chunk_"

    for chunk in "$temp_dir"/*.txt; do
        summarize_chunk "$chunk" "$filename"
    done

    echo "$filename" >> "$PROCESSED_FILES"
    log "Marked as processed: $filename"
}

# Process files in directory
process_files() {
    local dir="$1"
    log "Processing directory: $dir"

    shopt -s nullglob
    for file in "$dir"/*.txt; do
        local filename="$(basename "$file")"

        if [[ "$filename" == "overview.txt" ]]; then
            log "Skipping overview.txt"
            continue
        fi
        
        if [[ "$filename" == "detailed_summary.txt" ]]; then
            log "Skipping detailed_summary.txt"
            continue
        fi

        if is_processed "$filename"; then
            log "Already processed: $filename"
            continue
        fi

        process_file "$file"
    done
    shopt -u nullglob
}

# Recursive processing of subdirectories
process_subdirectories() {
    local parent_dir="$1"

    shopt -s nullglob
    for subdir in "$parent_dir"/*/; do
        [[ -d "$subdir" ]] && process_files "$subdir"
    done
    shopt -u nullglob
}

# Main execution flow
main() {
    trap 'log "Script interrupted"; exit 1' INT TERM

    initialize_logs
    process_files "$MAIN_DIR"
    process_subdirectories "$MAIN_DIR"

    log "Script completed"
}

main
