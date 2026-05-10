---
name: ai-ledger
description: >
  Audits code that AI wrote and maintains a running AI_LEDGER.md file so the user can
  understand and navigate their AI-generated codebase. Use this skill whenever the user
  wants to document, audit, or understand code Claude wrote — including phrases like
  "update the ledger", "audit what you built", "log this session", "I don't understand
  this code", "what did you write", or any time a coding session ends and the user wants
  a record of what was produced. Also trigger if the user pastes code and asks what it does.
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Glob
  - Grep
---

# AI Ledger Skill

Your job is to audit AI-written code and maintain `AI_LEDGER.md` — a living document that
lets the user quickly understand and navigate their codebase without having written it themselves.

## Step 1: Ask what to audit

Ask the user:

> "What should I audit? You can give me specific files, a directory, or just say 'everything'
> and I'll read the whole repo."

Wait for their answer before proceeding.

## Step 2: Read the code

Read all specified files in full using the appropriate tools. Do not skim. If given a
directory, list its contents first and read all non-trivial source files (skip lockfiles,
build artifacts, `.env` files, and binary assets).

## Step 3: Read existing AI_LEDGER.md (if it exists)

Check if `AI_LEDGER.md` exists in the repo root. If it does, read it fully — you'll need
to merge the new index entries with the existing ones rather than overwrite them.

## Step 4: Produce the audit

Run a thorough analysis of the code. For each file/module, identify:

- Every **function**: name, signature, what it does, side effects, key parameters
- Every **data structure / class / type**: name, fields, what it represents
- **Data flow**: how data moves through the system end to end
- **Design decisions**: non-obvious choices and why they were made
- **Gotchas**: anything fragile, surprising, or important to know before modifying

## Step 5: Write AI_LEDGER.md

Write (or overwrite) `AI_LEDGER.md` using the structure below. If the ledger already
exists, preserve all previous session entries and merge the index carefully — update
entries that changed, add new ones, mark removed ones as `[removed]`.

---

### AI_LEDGER.md format

```markdown
# AI Ledger

> Auto-maintained by Claude. Run the `ai-ledger` skill to update.

---

## Function & Data Structure Index

*Flat searchable index — Cmd+F for any function or type name.*

| Name | Type | File | Description |
|------|------|------|-------------|
| `functionName` | function | `path/to/file.py` | What it does in one line |
| `ClassName` | class | `path/to/file.py` | What it represents |
| `TypeName` | type/struct | `path/to/file.ts` | Fields and purpose |

---

## Sessions

### [YYYY-MM-DD] — Session N

**Files audited:** `file1.py`, `file2.ts`, ...

**Overview**
1–2 paragraph plain-English summary of what was built in this session, how the pieces
fit together, and the overall design intent.

**Functions introduced / modified**
- `functionName(param1, param2)` — What it does. Key behavior to know.
- ...

**Data structures introduced / modified**
- `StructName` — Fields: `field1` (type, purpose), `field2` (type, purpose). Used for X.
- ...

**Design decisions**
- Why X was done instead of Y, if non-obvious.
- ...

**Gotchas**
- Anything fragile, assumed, or surprising.
- What would break if you changed X.
- ...

---
```

---

## Formatting rules

- **Index first, sessions below** — the index is the primary navigation tool; sessions are
  the historical record.
- **Session N** is a counter across all sessions, not just today's (check existing sessions
  to increment correctly).
- Keep index entries to one line. Details live in the session entries.
- Use inline code formatting for all names: `functionName`, `ClassName`, `field`.
- If a function or type was already in the index from a previous session and was modified,
  update its index row and note the change in the new session entry.
- Write the overview in plain English — no jargon the user didn't introduce. Imagine
  explaining to yourself after a week away from the code.
