#!/usr/bin/env bash
# Install kit contents into ~/.cursor and ~/.claude (merge-friendly rsync).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIT="$(cd "$SCRIPT_DIR/.." && pwd)"
DRY_RUN="${DRY_RUN:-}"

mkdir -p "${HOME}/.cursor/skills" "${HOME}/.cursor/skills-cursor" "${HOME}/.cursor/rules" "${HOME}/.claude/skills"

run() {
  if [[ -n "$DRY_RUN" ]]; then
    printf 'DRY_RUN: '; printf '%q ' "$@"; echo
  else
    "$@"
  fi
}

run rsync -a "${KIT}/cursor-skills/" "${HOME}/.cursor/skills/"
run rsync -a "${KIT}/cursor-skills-cursor/" "${HOME}/.cursor/skills-cursor/"
run rsync -a "${KIT}/cursor-global-rules/" "${HOME}/.cursor/rules/"
run rsync -a "${KIT}/claude-skills/" "${HOME}/.claude/skills/"

echo "Done. Restart Cursor / Claude Code if they are running."
