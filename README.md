# Tooling

- **`ai-assistant-kit/`** — Portable Cursor skills, Cursor managed skills, global Cursor rules, and Claude Code skills. See [`ai-assistant-kit/README.md`](ai-assistant-kit/README.md).
- **`requirements/`** — Optional host dependencies for skills (e.g. Poppler and Python packages for **pdf-summarizer**). See [`requirements/README.md`](requirements/README.md).

This directory is its own **git repository** (so you can clone/push it without the rest of `gitrepos`).

## Push to GitHub

1. On GitHub: **New repository** → name e.g. `ai-tooling` → **no** README/license (this repo already has a commit).
2. From this folder:

```bash
cd /path/to/gitrepos/tooling
git remote add origin https://github.com/YOUR_USER/YOUR_REPO.git
git push -u origin main
```

SSH remote:

```bash
git remote add origin git@github.com:YOUR_USER/YOUR_REPO.git
git push -u origin main
```

**GitHub CLI** (optional): `gh auth login` then from `tooling/`:

```bash
gh repo create YOUR_REPO --private --source=. --remote=origin --push
```
