---
name: github-public-private-workflow
description: >-
  Configures git for a public OSS upstream (fetch-only) and private/internal origin (push target):
  dual remotes, public-main and private-main branches, and pub-pull / priv-pull / priv-push aliases.
  Optional global guardrails block accidental pushes to github.com. Use when setting up or using a
  dual-remote workflow, public upstream plus private mirror, pub-pull, priv-push, DISABLED upstream
  push URL, or github.com accidental-push prevention.
---

# Public upstream + private origin

## Rules

- Never push to public GitHub; only push to `origin` (private/internal).
- `upstream` is fetch-only; its push URL must be `DISABLED`.
- Work from `private-main` (or branches from it).
- Before any push: `git where` — confirm `origin` is not `github.com` and `upstream` push is `DISABLED`.

## One-time clone setup

Run from the **target git repository** you are configuring (not necessarily `journals`). Let `JOURNALS` be the path to a clone of this repo that contains `skills/`:

```bash
bash "$JOURNALS/skills/github-public-private-workflow/scripts/git-dual-remote-setup.sh"
```

Non-interactive:

```bash
PRIVATE_URL="https://github.<corp>.com/<org>/<repo>.git" bash "$JOURNALS/skills/github-public-private-workflow/scripts/git-dual-remote-setup.sh"
```

If you are configuring **`journals` itself**, `cd` to that repo and use `bash skills/github-public-private-workflow/scripts/git-dual-remote-setup.sh`.

## Optional global block (whole machine)

Run only when policy allows (mutates `~/.gitconfig` and global hooks). Use the script path inside your **journals** clone:

```bash
bash "$JOURNALS/skills/github-public-private-workflow/scripts/install-global-github-push-block.sh"
```

Override hook directory: `GIT_GLOBAL_HOOKS_DIR=/path/to/hooks bash "$JOURNALS/skills/.../install-global-github-push-block.sh"`

Verify:

```bash
git config --global --list | grep -E "pushInsteadOf|hooksPath"
```

## Daily commands

| Action | Command |
|--------|---------|
| Update `public-main` from upstream | `git pub-pull` |
| Update `private-main` from origin | `git priv-pull` |
| Push current HEAD to private | `git priv-push` |
| Show remotes | `git where` |

## Sync public OSS into private

```bash
git pub-pull
git switch private-main
git merge public-main   # or: git rebase public-main
git priv-push
```

## Human-readable reference

See [github-guidelines.md](../../guidelines/github-guidelines.md) in this repository for the full narrative and tables.

## Using this skill in Cursor

This skill lives under **`skills/`** in the repo (not under `.cursor/skills`). To load it as a project skill, symlink or copy this directory into your Cursor project skills path, or open this folder when following the workflow.
