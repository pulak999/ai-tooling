# AI assistant kit (Cursor + Claude Code)

Portable copy of **user-level** skills and global Cursor rules from this machine, kept **inside `gitrepos`** so you can `git` clone, tarball, or `rsync` the repo to another box and reinstall.

## What lives where (on any machine)

| Purpose | Typical path on disk | This kit folder |
|--------|----------------------|-----------------|
| Cursor **custom** skills (you wrote) | `~/.cursor/skills/` | `cursor-skills/` |
| Cursor **managed** skills (create-rule, shell, …) | `~/.cursor/skills-cursor/` | `cursor-skills-cursor/` |
| Cursor **global** rules (all projects) | `~/.cursor/rules/*.mdc` | `cursor-global-rules/` |
| Claude Code **skills** | `~/.claude/skills/` | `claude-skills/` |

**Project-only** Cursor rules (checked into a repo) stay in that repo, e.g. `gitrepos/.cursor/rules/project-memory.mdc` — they are **not** duplicated here.

## What we intentionally do *not* mirror

Do **not** copy these between machines via git (secrets, huge, or machine-specific):

- `~/.cursor/**` caches, `ide_state.json`, extension storage
- `~/.claude/.credentials.json`, plugin marketplaces, debug logs, `shell-snapshots/`
- `~/.claude/projects/**` (session transcripts; optional: copy only `memory/MEMORY.md` by hand if you want project notes portable)

Optional, local-only workflow dumps (not in this kit by default):

- `~/.cursor/plans/*.plan.md` — Cursor plan files; add a separate rsync if you want them in git.

## Quick install on a new machine

From this repo root:

```bash
./tooling/ai-assistant-kit/scripts/install-to-home.sh
```

Dry-run (prints `rsync` commands only):

```bash
DRY_RUN=1 ./tooling/ai-assistant-kit/scripts/install-to-home.sh
```

## Refresh this kit from your current home directory

After you edit skills in `~/.cursor` or `~/.claude`, pull changes **into** the repo before commit:

```bash
./tooling/ai-assistant-kit/scripts/import-from-home.sh
```

## Manual layout (if you hate scripts)

```bash
KIT=/path/to/gitrepos/tooling/ai-assistant-kit
rsync -a "$KIT/cursor-skills/"        ~/.cursor/skills/
rsync -a "$KIT/cursor-skills-cursor/" ~/.cursor/skills-cursor/
rsync -a "$KIT/cursor-global-rules/"  ~/.cursor/rules/
rsync -a "$KIT/claude-skills/"        ~/.claude/skills/
```

Restart Cursor / Claude Code after syncing.

## Suggested workflow

1. Treat **`tooling/ai-assistant-kit/`** as the source of truth for portable assistant config.
2. Edit skills either in the kit (then `install-to-home.sh`) or at home (then `import-from-home.sh` → commit).
3. Keep **repo-specific** rules next to code (e.g. `myproject/.cursor/rules/`).

## Contents snapshot (as of last import)

- **Cursor skills:** `code-review-phased`, `design-doc-review-bottleneck`
- **Cursor skills-cursor:** `create-rule`, `create-skill`, `create-subagent`, `migrate-to-skills`, `shell`, `update-cursor-settings` + `.cursor-managed-skills-manifest.json`
- **Cursor global rules:** `codebase-quizzer.mdc`
- **Claude skills:** `codebase-quizzer`, `format-latex`, `grill-me`, `implement-from-plan`, `plan-impact-analysis`, `phase-code-review.md`

Update this list in the README when you add skills.
