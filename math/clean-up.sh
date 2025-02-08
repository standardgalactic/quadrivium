#!/usr/bin/env bash
set -Eeuo pipefail

main_dir="$(pwd)"

cleanup_tmpdirs() {
  find "$main_dir" -type d -name 'tmp_*' -exec rm -rf {} +
}

cleanup_tmpdirs
