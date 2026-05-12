#!/usr/bin/env bash
# List indexable documents under a folder (depth 2, skip README.md).
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "usage: list-docs.sh <folder>" >&2
  exit 1
fi

folder="$(cd "$1" && pwd)"
find "$folder" -maxdepth 2 -type f \( \
  -iname '*.pdf' -o \
  -iname '*.docx' -o \
  -iname '*.doc' -o \
  -iname '*.txt' -o \
  -iname '*.md' \
\) ! -iname 'README.md' | LC_ALL=C sort
