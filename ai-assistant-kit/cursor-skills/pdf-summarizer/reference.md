# PDF and document extraction reference

Install host tools first: `requirements/pdf-summarizer/install.sh` from the **ai-tooling** repo root.

## PDFs

**Inspect:**

```bash
pdfinfo /path/to/file.pdf
pdftotext -f 1 -l 3 /path/to/file.pdf - | head -60
```

**Full text (preferred order):**

```bash
~/.cursor/skills/pdf-summarizer/scripts/extract-text.sh /path/to/file.pdf
```

Or manually: `pdftotext -layout`, then PyMuPDF (`import fitz`), then `pdftoppm` at 120 DPI for only the pages you need.

**Long PDFs (40+ pages):** abstract, intro, and conclusion first; methods or appendices only when the question requires them.

**Scanned PDFs:** avoid whole-document rasterization. Sample pages, or install OCR (`tesseract-ocr`, `ocrmypdf`) if you need full text.

## Word / DOCX

```bash
python3 -c "
from docx import Document
doc = Document('/path/to/file.docx')
print('\n'.join(p.text for p in doc.paragraphs))
"
```

## Markdown / plain text

Read with the editor Read tool or `cat`.

## Google Docs / Drive

Only when a Google Drive MCP is connected. Otherwise ask for an export (PDF/DOCX) into the indexed folder.

## Token budget

Text extraction is roughly 200–400 tokens per page; rasterized pages are much higher (~1,600 tokens/page at 150 DPI). Prefer text extraction and targeted page ranges.
