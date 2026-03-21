#!/usr/bin/env bash
# Copy from ~/.cursor and ~/.claude into this kit (for git commit / backup).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIT="$(cd "$SCRIPT_DIR/.." && pwd)"
DRY_RUN="${DRY_RUN:-}"

mkdir -p "${KIT}/cursor-skills" "${KIT}/cursor-skills-cursor" "${KIT}/cursor-global-rules" "${KIT}/claude-skills"

run() {
  if [[ -n "$DRY_RUN" ]]; then
    printf 'DRY_RUN: '; printf '%q ' "$@"; echo
  else
    "$@"
  fi
}

run rsync -a --delete "${HOME}/.cursor/skills/" "${KIT}/cursor-skills/"
run rsync -a --delete "${HOME}/.cursor/skills-cursor/" "${KIT}/cursor-skills-cursor/"
run rsync -a "${HOME}/.cursor/rules/" "${KIT}/cursor-global-rules/"
run rsync -a --delete "${HOME}/.claude/skills/" "${KIT}/claude-skills/"

echo "Kit updated under: ${KIT}"
echo "Review with git diff, then commit if looks good."
