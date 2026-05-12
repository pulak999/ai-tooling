---
name: pdf-summarizer
description: >
  Indexes and summarizes a folder of documents (PDF, DOCX, Word, Markdown, plain text, and
  optionally Google Docs when a Drive MCP is connected) into a persistent README.md cache.
  Use when the user wants to summarize, index, or query a document folder — lit reviews,
  plans, papers, specs, meeting notes, or mixed collections. Triggers on: "summarize my
  docs/papers/plans", "index this folder", "what do these documents say about X", "add this
  to my index", "refresh my summaries", or "what does [doc] cover". Prefer this skill for
  folder-scale work; do not route single-file coding reads through the index unless the user
  asked to index that folder.
---

# PDF Summarizer

Indexes a document folder into a persistent `README.md` cache. Sources are read once; later
questions are answered from the index unless the user needs quotes, tables, or a refresh.

**Host setup:** from the **ai-tooling** repo root, run `requirements/pdf-summarizer/install.sh`,
then `ai-assistant-kit/scripts/install-to-home.sh`. Helper scripts live in this skill's
`scripts/` directory after install.

---

## Core principle: README-first, file-lazy

**Load `README.md` in the target folder first.** Open a source file only if:

- It has no complete entry in the README, or
- The user needs detail the summary cannot answer (exact figures, tables, quoted passages), or
- The user says "re-read", "refresh", or `check-stale.sh` reports `STALE` / `MISSING`

---

## Step 1 — Locate the folder and load the README

If the user did not give a path, search likely locations or ask once.

```bash
cat /path/to/folder/README.md 2>/dev/null || echo "NO README — will create one"
~/.cursor/skills/pdf-summarizer/scripts/list-docs.sh /path/to/folder
~/.cursor/skills/pdf-summarizer/scripts/check-stale.sh /path/to/folder
```

**Google Docs / Drive:** only if a Drive MCP is connected; otherwise use files in the folder or
ask for an export.

If the README exists, read it fully before opening sources.

---

## Step 2 — Classify each document

| Status | Action |
|--------|--------|
| Complete README entry | **Skip** — answer from README |
| On disk, missing from README | **Summarize** → write entry |
| `check-stale.sh` → `STALE` or `[STALE]` in README | **Re-summarize** in place |
| Question beyond the summary | **Re-read that file only** (section or page range) |

---

## Step 3 — Read and extract content

See `reference.md` in this skill directory for PDF, DOCX, and fallback extraction.

**PDFs:** `pdfinfo`, sample pages with `pdftotext`, full text via `extract-text.sh`. For 40+
pages, start with abstract, intro, and conclusion.

**DOCX:** `python-docx` (installed via requirements).

**Markdown / text:** Read directly.

---

## Step 4 — Generate the summary

Use this five-point framework. Be concrete — two to five sentences per point:

1. **What is the problem?** — gap, failure, or goal.
2. **Why is it hard?** — core tension or constraints (tradeoffs for plans/specs).
3. **Obvious solution and why it fails** — strawman, or what was ruled out.
4. **Actual solution / proposal** — mechanism, architecture, or decision in two to three sentences.
5. **Technical details worth remembering** — numbers, owners, open questions, failure modes.

---

## Step 5 — Write the entry to README.md

Create or update `README.md` in the indexed folder. **Update entries in place** between
`<!-- doc: ... -->` and `<!-- end: ... -->`; do not duplicate keys.

```markdown
<!-- doc: exact-filename-or-id -->
## Title of the Document

**Source:** `filename.pdf`  
**Type:** paper | plan | spec | notes | other  
**Summarized:** YYYY-MM-DD  
**Tags:** #tag1 #tag2 #tag3

**Problem:** …

**Why it's hard:** …

**Obvious solution & why it fails:** …

**Actual solution:** …

**Details worth remembering:** …

---
<!-- end: exact-filename-or-id -->
```

**Header** (once per README):

```markdown
# Document Index

Auto-maintained by the pdf-summarizer skill. Sources are re-read only when new, stale, or when
a question needs more detail than this index.

**Last updated:** YYYY-MM-DD  
**Documents indexed:** N

## Contents

| Document | Type | Tags | Hook |
|----------|------|------|------|
| Title | plan | #gpu #virt | One-line takeaway |

> Search: title, filename, or tag (e.g. `#inference`).

---
```

Refresh the **Contents** table whenever entries change.

---

## Step 6 — Answering questions

Answer from the README. Re-open a source only for quotes, specific tables/appendices, or gaps
in the summary. Fetch **sections or page ranges**, not whole files when possible.

Optional note on the entry:

```markdown
**Notes:** [YYYY-MM-DD] Table 3: p99 latency 12ms at 200 req/s.
```

---

## Step 7 — Staleness

Run `check-stale.sh` before bulk refresh. Treat output `STALE` / `MISSING` and user "refresh"
as re-summarize. Compare source mtime to **Summarized:**; mark `[STALE]` in the title until
updated.

---

## Tips

- **Batch:** index all new files in one pass; write the README once at the end.
- **Tags:** keep README entries grep-friendly for cross-doc questions.
- **Mixed folders:** one README for PDFs, DOCX, and text in the same directory.
- **Non-research docs:** map problem → goal, hard → constraints, solution → plan.
