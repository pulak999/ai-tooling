#!/usr/bin/env bash
# Compare source mtimes to Summarized: dates in folder/README.md.
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "usage: check-stale.sh <folder>" >&2
  exit 1
fi

folder="$(cd "$1" && pwd)"
readme="$folder/README.md"

if [[ ! -f "$readme" ]]; then
  echo "NO README — all documents need indexing"
  exit 0
fi

python3 - "$folder" "$readme" <<'PY'
import re
import sys
from datetime import date, datetime
from pathlib import Path

folder = Path(sys.argv[1])
readme = Path(sys.argv[2]).read_text(encoding="utf-8", errors="replace")

summarized: dict[str, date] = {}
for block in re.split(r"<!--\s*doc:\s*", readme)[1:]:
    key = block.split("-->", 1)[0].strip()
    m = re.search(r"\*\*Summarized:\*\*\s*(\d{4}-\d{2}-\d{2})", block)
    if m:
        summarized[key] = date.fromisoformat(m.group(1))

seen: set[Path] = set()
for path in folder.rglob("*"):
    if path.is_dir():
        continue
    if path.name == "README.md":
        continue
    if path.suffix.lower() not in {".pdf", ".docx", ".doc", ".txt", ".md"}:
        continue
    if len(path.relative_to(folder).parts) > 2:
        continue
    seen.add(path.resolve())

for path in sorted(seen):
    key = path.name
    mtime = datetime.fromtimestamp(path.stat().st_mtime).date()
    if key not in summarized:
        print(f"MISSING\t{path}")
        continue
    if mtime > summarized[key]:
        print(f"STALE\t{path}\t(mtime {mtime}, summarized {summarized[key]})")
PY
