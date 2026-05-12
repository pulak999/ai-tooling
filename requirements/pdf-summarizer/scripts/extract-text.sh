#!/usr/bin/env bash
# Extract text from a PDF: Poppler, then PyMuPDF, then page JPEGs for vision.
set -euo pipefail

usage() {
  echo "usage: extract-text.sh <file.pdf> [out.txt]" >&2
  exit 1
}

[[ $# -ge 1 ]] || usage

src="$1"
out="${2:-}"

if [[ ! -f "$src" ]]; then
  echo "not found: $src" >&2
  exit 1
fi

if [[ -z "$out" ]]; then
  out="$(mktemp /tmp/pdf-summarizer-XXXXXX.txt)"
  trap 'rm -f "$out"' EXIT
fi

if command -v pdftotext >/dev/null 2>&1; then
  if pdftotext -layout "$src" "$out" 2>/dev/null && [[ -s "$out" ]]; then
    cat "$out"
    exit 0
  fi
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PY="$SCRIPT_DIR/../.venv/bin/python"
if [[ ! -x "$PY" ]]; then
  PY="python3"
fi

if "$PY" -c "import fitz" 2>/dev/null; then
  "$PY" - "$src" "$out" <<'PY'
import sys
from pathlib import Path

import fitz

src, out = sys.argv[1], sys.argv[2]
doc = fitz.open(src)
text = "\n\n".join(page.get_text("text") for page in doc)
Path(out).write_text(text, encoding="utf-8")
print(text)
PY
  exit 0
fi

if command -v pdftoppm >/dev/null 2>&1; then
  tmpdir="$(mktemp -d /tmp/pdf-summarizer-pages-XXXXXX)"
  trap 'rm -rf "$tmpdir"' EXIT
  pdftoppm -jpeg -r 120 -f 1 -l 5 "$src" "$tmpdir/page"
  echo "TEXT_EXTRACTION_FAILED: rasterized first pages in $tmpdir" >&2
  ls "$tmpdir"/page-*.jpg
  exit 2
fi

echo "Install poppler-utils or pymupdf (see requirements/pdf-summarizer/README.md)" >&2
exit 1
