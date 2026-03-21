---
name: implement-from-plan
description: >
  Use this skill whenever the user provides a plan file (markdown, spec, or design doc) and asks
  you to implement it. Triggers on phrases like "implement this", "build this from the plan",
  "let's do this", "implement @<file>", or any request that combines a reference to a plan/spec
  file with an instruction to execute it. The skill enforces disciplined implementation:
  thorough code review before touching anything, structured doc updates, per-chunk test split
  approval, frequent check-ins, GitHub pushes with CI awareness, and hard stops when things are
  ambiguous or broken. Use it even if the user's request is casual — "lets do so" paired with a
  plan file reference is a clear trigger.
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - Agent
  - TodoWrite
---

# Implement From Plan

You are implementing a software project from a plan file. Your job is to execute faithfully,
test constantly, communicate clearly, and never go silent for long.

---

## Step 0: Read, Review, and Resolve

Complete all substeps fully before writing a single line of code.

### 0.1 — Read the plan completely
Read the entire plan file before doing anything else. Do not skim.

### 0.2 — 3-phase code review of the relevant codebase
Follow `~/.claude/skills/phase-code-review.md` exactly. That skill owns the review format,
the cache-check logic (SHA-keyed against `code.md`), and when to skip vs. re-run. Do not
inline or duplicate its logic here.

### 0.3 — Cross-reference plan vs codebase
After the code review, explicitly note:
- Which parts of the plan are already partially or fully implemented
- Which parts have dependencies or preconditions that must be handled first
- Any conflicts between the plan and the current codebase state

Add this cross-reference section to `code.md`.

### 0.4 — Resolve all ambiguities before proceeding
If **anything** in the plan is unclear, underspecified, or contradictory — stop and ask the
user before writing a single line of code. Do not make assumptions on ambiguous specs. This is
a hard rule. Only proceed when you have clarity.

Examples of things that require a stop:
- An interface or API is mentioned but not defined
- A step says "handle errors appropriately" without specifying how
- Two sections of the plan seem to contradict each other
- A dependency or tool is referenced but not pinned/specified

Examples of things you can resolve yourself (no need to ask):
- Naming a helper function not mentioned in the plan
- Choosing idiomatic code style for the language
- Deciding import order

### 0.5 — Survey existing tests and CI workflows
- Find and read the existing test suite and how to run it
- Read all files in `.github/workflows/` carefully — understand what each workflow triggers on,
  what it tests or builds, and how to read pass/fail with `gh run list` / `gh run view <run-id>`
- Note any gaps: tests that don't exist yet, workflows that would be affected by plan changes

---

## Step 1: Update Project Docs

Update the following files based on your understanding of the plan and codebase. Create any
that do not exist.

**CLAUDE.md** — Add or update:
- Project overview (if missing or stale)
- Build instructions
- Code conventions
- Key design decisions relevant to this plan

**ARCH.md** — Add or update:
- Architecture overview
- Component responsibilities
- Data flow
- Any new components or changes introduced by the plan

**TODO.md** — Replace or update with:
- Tasks from the plan, broken into concrete actionable items
- Mark anything already done as complete
- Order tasks by dependency

After updating all three files, **hard stop and ask the user**:
> "I've completed the code review (written to `code.md`) and updated CLAUDE.md, ARCH.md, and
> TODO.md based on the plan. Do you want to add any context, correct anything, or adjust scope
> before I begin implementation?"

Wait for the user's response before proceeding to Step 2.

---

## Step 2: Break Into Chunks and Get Per-Chunk Approval

Decompose the plan into ordered, testable implementation chunks. Each chunk should be small
enough that you can implement it, test it, and describe what you did in a few sentences.

For **each chunk**, before implementing it, present all of the following and wait for explicit
user approval before writing any code for that chunk:

1. **What code will be written:** List every file you intend to create or modify and describe
   exactly what changes you will make. Call out any risky or irreversible changes.

2. **Recommended test split:** State clearly which tests you recommend writing as local unit
   tests vs. CI workflow checks, and why. Use this exact format:

   > "I recommend writing X as a local unit test because [reason — e.g., fast, no external
   > deps, tests logic in isolation]. I recommend writing Y as a CI workflow check because
   > [reason — e.g., requires secrets, cross-platform, or duplicates local coverage if run
   > locally]. Approve this split or redirect me."

   The goal is to keep local tests and CI **complementary, not overlapping**. Local tests cover
   logic fast; CI handles environment-sensitive checks, cross-platform builds, publishing steps,
   or anything requiring infra not available locally. Never duplicate the same test in both
   layers.

Do not present all chunks at once and ask for a single bulk approval. Present one chunk, get
approval, implement it, check in, then present the next chunk. This keeps each approval
decision concrete and grounded.

---

## Step 3: Implement Approved Chunks

Once the user approves a chunk's code plan and test split, implement it. Follow the project's
existing code conventions (from CLAUDE.md). Work through TODO.md top to bottom, marking items
complete as you go.

After implementing each chunk, deliver a check-in using the format below, push to GitHub if
tests pass, check CI status, then present the next chunk for approval (back to Step 2).

### The Check-in Format

Every check-in must follow this exact structure. No freeform updates.

```
## Check-in [N]

**Just implemented:** <1–3 sentences on what changed>

**Test / CI status:**
- Local tests: PASS / FAIL / SKIPPED (with reason)
- CI: <workflow name> — PASS / FAIL / PENDING / NOT YET PUSHED
- If anything is FAIL: see Blockers below

**Blockers / open questions:**
- <list any blockers, or "None">

**Up next:** <what the next chunk is>
```

Never skip any field. If tests haven't run yet, say so explicitly.

### Check-in trigger points (mandatory regardless of judgment):
- After completing Step 0 and Step 1 (before writing any code)
- After each chunk is implemented and tested
- Whenever tests fail or CI fails — full stop, check in immediately
- Whenever you hit something ambiguous mid-implementation (see Step 0.4)
- After every 2–3 chunks, even if everything is going smoothly
- When you're about to do something irreversible (delete files, change a schema, etc.)

The rule of thumb: if you've been implementing without talking to the user for what feels like
"a while", you've waited too long. Err heavily on the side of more check-ins, not fewer.

### Push rhythm:
Push after each chunk that passes tests. Don't batch up multiple chunks before pushing. Use
descriptive commit messages that reference the plan section being implemented.

Commit message format:
```
[plan: <section name>] implement <what you did>

- bullet of key change
- bullet of key change
```

Never push with failing local tests. Never push without first checking CI status on the
previous push.

### After each push:
Check CI status before starting the next chunk. If CI is running, note it as PENDING in your
check-in. If CI fails:
- Stop immediately
- Report the failure in a check-in
- Do not proceed until the user says how to handle it

Use CI as a signal, not a formality. If the workflow tests something your local run doesn't
cover, CI failure is a real blocker.

### Additional testing rules:
- Run the existing test suite after every chunk, even if your change "obviously" wouldn't
  break anything
- If the project has no tests yet, write at least a smoke test for each chunk before moving on
- Never mark a chunk complete if tests are failing
- If a test fails that you didn't write and don't understand, stop and ask — don't delete or
  skip it

---

## Step 4: Hard Stops

Stop and ask the user in these situations. Do not attempt to work around them:

| Situation | Action |
|---|---|
| Ambiguous spec | Ask before implementing |
| Test failure (local or CI) | Stop, report, wait |
| Conflict between plan and existing code | Ask which wins |
| A step would require deleting or restructuring existing files | Ask first |
| You're unsure if a dependency is safe to add | Ask |
| Plan references something that doesn't exist in the repo | Ask |
| About to write tests for a chunk | Present test split recommendation and wait for approval |

---

## Step 5: Wrapping Up

When the full plan is implemented:

1. Run the complete test suite one final time.
2. Check that CI is green on the final push.
3. Write a `LOG.md` entry in the same directory as the plan file (create it if it does not
   exist). Append one entry per session using the format below.
4. Give a final check-in summarizing: what was built, test status, any deviations from the
   plan (and why), and any follow-up items the user should know about.

Do not declare "done" if any tests are failing or CI is red.

### LOG.md entry format

```
## [YYYY-MM-DD] <Plan title or short description>

### Features Implemented
- <bullet per feature>

### Files Changed
| File | What changed |
|------|-------------|
| path/to/file | Description of change |

### Functions Written
| Function | File | Description |
|----------|------|-------------|
| function_name | path/to/file | What it does |

### Data Structures Created
| Name | File | Description |
|------|------|-------------|
| StructName | path/to/file | Fields and purpose |

### Notes
- Any caveats, known issues, or follow-up items
```

Be specific. The LOG.md is used for context compaction — it must be self-contained enough that
a future session can understand what was done without reading the code.
