#!/usr/bin/env bash
# Install pdf-summarizer host dependencies and copy helper scripts into skill dirs.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
DRY_RUN="${DRY_RUN:-}"

run() {
  if [[ -n "$DRY_RUN" ]]; then
    printf 'DRY_RUN: '; printf '%q ' "$@"; echo
  else
    "$@"
  fi
}

install_apt() {
  if ! command -v apt-get >/dev/null 2>&1; then
    echo "apt-get not found; install poppler-utils manually (pdfinfo, pdftotext, pdftoppm)." >&2
    return 0
  fi
  if command -v pdfinfo >/dev/null 2>&1 && command -v pdftotext >/dev/null 2>&1; then
    echo "Poppler CLI already on PATH."
    return 0
  fi
  if ! command -v sudo >/dev/null 2>&1; then
    echo "sudo not available; install poppler-utils manually." >&2
    return 0
  fi
  if ! sudo -n true 2>/dev/null; then
    echo "Poppler not installed; run: sudo apt-get install -y poppler-utils" >&2
    return 0
  fi
  run sudo apt-get update
  run sudo apt-get install -y poppler-utils
}

venv_python() {
  local venv_py="$SCRIPT_DIR/.venv/bin/python"
  if [[ -x "$venv_py" ]]; then
    echo "$venv_py"
    return 0
  fi
  if command -v python3 >/dev/null 2>&1; then
    echo "python3"
    return 0
  fi
  return 1
}

install_python() {
  local py
  py="$(venv_python)" || {
    echo "python3 not found; install Python 3 before pip packages." >&2
    return 1
  }

  if [[ "$py" == "python3" ]] && python3 -m pip --version >/dev/null 2>&1; then
    run python3 -m pip install --user -r "$SCRIPT_DIR/requirements.txt"
    return 0
  fi

  if [[ ! -x "$SCRIPT_DIR/.venv/bin/python" ]]; then
    run python3 -m venv "$SCRIPT_DIR/.venv"
  fi
  run "$SCRIPT_DIR/.venv/bin/python" -m pip install -U pip
  run "$SCRIPT_DIR/.venv/bin/python" -m pip install -r "$SCRIPT_DIR/requirements.txt"
}

install_scripts() {
  local dest
  for dest in \
    "${HOME}/.cursor/skills/pdf-summarizer" \
    "${HOME}/.claude/skills/pdf-summarizer"; do
    run mkdir -p "$dest/scripts"
    run cp -a "$SCRIPT_DIR/scripts/." "$dest/scripts/"
    run chmod +x "$dest/scripts/"*
  done
}

install_apt
install_python
install_scripts

echo "pdf-summarizer requirements installed."
echo "Sync skills: $REPO_ROOT/ai-assistant-kit/scripts/install-to-home.sh"
