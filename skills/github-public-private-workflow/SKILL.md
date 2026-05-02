---
name: github-public-private-workflow
description: >-
  Safe git workflow for OSS upstream + private mirror: public upstream fetch-only (push DISABLED),
  private origin as sole push target, public-main and private-main branches, aliases pub-pull /
  priv-pull / priv-push / where. Optional machine-wide block for accidental pushes to github.com
  via pushInsteadOf and global pre-push hook (scripts included). Use when configuring dual remotes,
  syncing upstream into private lab mirror, release workflow with internal github host, or
  preventing pushes to public GitHub.
---

# Public upstream + private origin

## Purpose

Use when you develop **open source** on public GitHub but maintain a **private/internal mirror** for lab-only changes. Prevents accidental public pushes and keeps upstream merges straightforward.

## Non-negotiable rules

- **Never push to public GitHub.**
- `upstream` is **fetch-only** (push URL must be **`DISABLED`**).
- Only push to **`origin`** (private/internal).
- Work on **`private-main`** or feature branches created from it.
- Before any push: **`git where`** and verify `origin` is **not** `github.com` and `upstream` push URL is **`DISABLED`**.

## Remotes and branch model

- **`upstream`** — public GitHub repo (fetch-only; push disabled).
- **`origin`** — private/internal host (**only** push target).

Local branches:

- **`public-main`** tracks `upstream/main` (adjust if your default branch is not `main`).
- **`private-main`** tracks `origin/main`.

Create work branches from **`private-main`**; push only to **`origin`**.

## One-time setup

Run from the **target git repository** root. Let **`JOURNALS`** be the path to a clone of this repo that contains `skills/`:

```bash
bash "$JOURNALS/skills/github-public-private-workflow/scripts/git-dual-remote-setup.sh"
```

Non-interactive:

```bash
PRIVATE_URL="https://github.<corp>.com/<org>/<repo>.git" bash "$JOURNALS/skills/github-public-private-workflow/scripts/git-dual-remote-setup.sh"
```

If you are configuring **`journals` itself**: `bash skills/github-public-private-workflow/scripts/git-dual-remote-setup.sh` from the journals repo root.

Scripts:

- [`scripts/git-dual-remote-setup.sh`](scripts/git-dual-remote-setup.sh) — remotes, branches, aliases.
- [`scripts/install-global-github-push-block.sh`](scripts/install-global-github-push-block.sh) — optional global guardrails (below).

## Global enforcement: accidental github.com pushes

Per-repo setup can still miss a wrong remote. Install **`pushInsteadOf`** (hard fail) plus a global **`pre-push`** hook (readable message):

```bash
bash "$JOURNALS/skills/github-public-private-workflow/scripts/install-global-github-push-block.sh"
```

Uses `~/.git-global-hooks/` by default; override with `GIT_GLOBAL_HOOKS_DIR`. **`pushInsteadOf`** surfaces transport errors; hooks can be skipped with **`git push --no-verify`** (avoid unless policy allows).

| | `pushInsteadOf` | Global `pre-push` |
|---|---|---|
| Role | Hard block | Clear message |
| Custom message | No | Yes |
| Bypass | Harder | `--no-verify` |

Verify:

```bash
git config --global --list | grep -E "pushInsteadOf|hooksPath"
```

## Daily commands

| Action | Command |
|--------|---------|
| Pull `public-main` from upstream | `git pub-pull` |
| Pull `private-main` from origin | `git priv-pull` |
| Push current HEAD to private | `git priv-push` |
| Show remotes | `git where` |

Switch tracking branches:

```bash
git switch public-main
git switch private-main
```

Expect **`git where`** to show `upstream` push URL **`DISABLED`**.

## Sync public OSS into private

Merge:

```bash
git pub-pull
git switch private-main
git merge public-main
git priv-push
```

Or rebase:

```bash
git pub-pull
git switch private-main
git rebase public-main
git priv-push
```

## Rules for coding agents

- Never push to **`upstream`**; only to **`origin`**.
- Prefer **`private-main`** for work that will be pushed.
- Treat public GitHub as **read-only** in this clone.
- Confirm **`git where`** before pushing.
- Where policy allows, install global block via **`install-global-github-push-block.sh`**; do not use **`--no-verify`** unless explicitly instructed.

## Examples

Sync OSS into private and push:

```bash
git pub-pull
git switch private-main
git merge public-main
git priv-push
```

Sanity-check before push:

```bash
git where
```

## Using this skill in Cursor

This directory lives under **`skills/`** in the journals repo (not `.cursor/skills`). Symlink or copy it into your Cursor project skills path if you want automatic loading, or attach **`SKILL.md`** when working this workflow.
