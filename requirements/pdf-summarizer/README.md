# pdf-summarizer requirements

System and Python packages for the **pdf-summarizer** skill (Poppler CLI, DOCX extraction, PDF text fallback).

## Install

From the **ai-tooling** repo root:

```bash
./requirements/pdf-summarizer/install.sh
```

Dry-run (print commands only):

```bash
DRY_RUN=1 ./requirements/pdf-summarizer/install.sh
```

Then install or refresh skills:

```bash
./ai-assistant-kit/scripts/install-to-home.sh
```

Restart Cursor / Claude Code if they are running.

## What gets installed

- **APT (Debian/Ubuntu):** `poppler-utils` (`pdfinfo`, `pdftotext`, `pdftoppm`)
- **Python:** `python-docx`, `pymupdf` from `requirements.txt` (user site, or `requirements/pdf-summarizer/.venv` when system `pip` is unavailable)
- **Helper scripts** copied to `~/.cursor/skills/pdf-summarizer/scripts/` and `~/.claude/skills/pdf-summarizer/scripts/`

## Verify

```bash
command -v pdfinfo pdftotext pdftoppm
requirements/pdf-summarizer/.venv/bin/python -c "import docx, fitz; print('python deps ok')"
~/.cursor/skills/pdf-summarizer/scripts/list-docs.sh /path/to/folder
```

## Manual install

**Debian/Ubuntu:**

```bash
sudo apt-get update
sudo apt-get install -y poppler-utils
```

**Python:**

```bash
python3 -m pip install --user -r requirements/pdf-summarizer/requirements.txt
```

**Scripts only** (after skills are synced):

```bash
KIT=./ai-assistant-kit
for dest in "$HOME/.cursor/skills/pdf-summarizer" "$HOME/.claude/skills/pdf-summarizer"; do
  mkdir -p "$dest/scripts"
  cp requirements/pdf-summarizer/scripts/* "$dest/scripts/"
  chmod +x "$dest/scripts/"*
done
```

## Notes

- Prefer `pdftotext` when Poppler is available; `extract-text.sh` falls back to PyMuPDF, then page images for scanned PDFs.
- Google Drive / Docs: only when a Drive MCP is connected; otherwise use exported PDF or DOCX in the folder.
- OCR is not installed by default; see `reference.md` in the skill folder after sync.
