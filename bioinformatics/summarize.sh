#!/usr/bin/env bash
set -Eeuo pipefail

# Number of lines per chunk
CHUNK_LINES=100

SUMMARY_COMMAND=("ollama" "run" "vanilj/phi-4")
PROGRESS_FILE="progress.log"

main_dir="$(pwd)"
touch "$main_dir/$PROGRESS_FILE"

log() {
    local message="[$(date '+%H:%M:%S')] $*"
    echo "$message" | tee -a "$main_dir/$PROGRESS_FILE"
}

is_processed() {
    local file_path="$1"
    grep -Fxq "$file_path" "$main_dir/$PROGRESS_FILE"
}

mark_processed() {
    echo "$1" >> "$main_dir/$PROGRESS_FILE"
}

cleanup_tempdirs() {
    [[ -n "${TEMP_DIRS_CREATED:-}" ]] && rm -rf $TEMP_DIRS_CREATED
}
trap cleanup_tempdirs EXIT

process_files_in_directory() {
    local dir="$1"
    shopt -s nullglob
    local all_files=("$dir"/*.txt)
    shopt -u nullglob

    [[ ${#all_files[@]} -eq 0 ]] && return

    for file in "${all_files[@]}"; do
        [[ -f "$file" && ! -L "$file" ]] || continue
        if is_processed "$file"; then continue; fi

        log "Processing: $(basename "$file")"
        local temp_dir
        temp_dir="$(mktemp -d)"
        TEMP_DIRS_CREATED="${TEMP_DIRS_CREATED:-} $temp_dir"

        local preprocessed_file="$temp_dir/preprocessed.txt"
        cp "$file" "$preprocessed_file"
        split -l "$CHUNK_LINES" -- "$preprocessed_file" "$temp_dir/chunk_"

        local summary_file="$dir/$(basename "${file%.txt}")-overview.txt"
        touch "$summary_file"

        for chunk_file in "$temp_dir"/chunk_*; do
            [[ -f "$chunk_file" ]] || continue
            log "  Processing chunk: $(basename "$chunk_file")"
            { 
                echo "Summarize the following text."
                cat "$chunk_file"
            } | "${SUMMARY_COMMAND[@]}" 2>>"$main_dir/$PROGRESS_FILE" | tee -a "$summary_file"
        done

        mark_processed "$file"
        log "Done: $(basename "$file")"
    done
}

process_files_in_directory "$main_dir"

process_subdirectories() {
    local parent_dir=$1
    for dir in "$parent_dir"/*/; do
        [[ -d "$dir" ]] && process_files_in_directory "$dir" && process_subdirectories "$dir"
    done
}

process_subdirectories "$main_dir"
