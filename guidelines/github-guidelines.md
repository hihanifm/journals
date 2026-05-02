---

## name: github-public-upstream-private-origin

description: Safe git workflow for OSS upstream + private mirror (disable public pushes, sync via public-main/private-main)
version: 1.2
applies_to: ["git", "github", "release-workflow"]
rules:

- Never push to public GitHub
- upstream is fetch-only; upstream push URL must be DISABLED
- Only push to origin (private/internal)
- Prefer working on private-main or branches from it
- Before any push, run `git where` and verify remotes
- Optional belt-and-suspenders: run `skills/github-public-private-workflow/scripts/install-global-github-push-block.sh` (or equivalent manual git config); verify with `git config --global --list | grep -E 'pushInsteadOf|hooksPath'`
usage:
- Run `skills/github-public-private-workflow/scripts/git-dual-remote-setup.sh` from a journals clone (see Cursor skill `skills/github-public-private-workflow/SKILL.md`)
- Use aliases: pub-pull, priv-pull, priv-push

# SKILL: Public upstream + private origin Git workflow

## Agent skill + scripts (canonical)

Versioned scripts and a Cursor-oriented skill live in this repository:

- **Skill:** [`skills/github-public-private-workflow/SKILL.md`](../skills/github-public-private-workflow/SKILL.md)
- **Dual-remote setup:** [`skills/github-public-private-workflow/scripts/git-dual-remote-setup.sh`](../skills/github-public-private-workflow/scripts/git-dual-remote-setup.sh)
- **Optional global github.com push block:** [`skills/github-public-private-workflow/scripts/install-global-github-push-block.sh`](../skills/github-public-private-workflow/scripts/install-global-github-push-block.sh)

Prefer running those files rather than copying shell from this document.

## Purpose

Use this workflow when you develop a project **open source** on public GitHub, but also maintain a **private/internal mirror** for lab-only changes. It prevents accidental public pushes and keeps upstream merges smooth.

## Non‑negotiable rules (agents must honor)

- **Never push to public GitHub**.
- `upstream` is **fetch-only** (its push URL must be **DISABLED**).
- Only push to `origin` (private/internal).
- Do work on `private-main` (or feature branches created from it).
- Before any push: run `git where` and verify:
  - `origin` is **not** `github.com`
  - `upstream` push URL is **DISABLED**

---

## Global enforcement: block accidental github.com pushes

Per-repo setup still leaves room for a wrong remote or a clone aimed at public GitHub. **Install both** `pushInsteadOf` (hard fail) and a global `pre-push` hook (clear message) via (path = your **journals** clone):

```bash
bash /path/to/journals/skills/github-public-private-workflow/scripts/install-global-github-push-block.sh
```

That script writes global git config and `~/.git-global-hooks/pre-push` (override directory with `GIT_GLOBAL_HOOKS_DIR`). **`pushInsteadOf`** yields transport errors; **hooks** can be skipped with `git push --no-verify`.

| | `pushInsteadOf` | Global `pre-push` |
|---|---|---|
| Setup | Two config entries (script applies them) | Hook file + `hooksPath` |
| Custom error message | No | Yes |
| Bypass | Harder | `--no-verify` |

Verify:

```bash
git config --global --list | grep -E "pushInsteadOf|hooksPath"
```

---

## Remotes and branch model

- `**upstream`** = public GitHub repo (**fetch-only**; pushing is disabled)
- `**origin`** = private/internal GitHub repo (**the only push target**)

Two local “main equivalents”:

- `**public-main`** tracks `upstream/main`
- `**private-main`** tracks `origin/main`

Work branches should be created from `**private-main`** and pushed only to `**origin`**.

---

## One-time setup (run in a fresh clone)

Run from the **target git repo’s root** (the project you are configuring). Use the script path inside your **journals** checkout:

```bash
bash /path/to/journals/skills/github-public-private-workflow/scripts/git-dual-remote-setup.sh
```

If you are already inside the journals repo and configuring another clone, adjust the path accordingly.

### Cline / non-interactive quick-start

Run from the **target project** repo root; point at the script inside your **journals** checkout:

```bash
PRIVATE_URL="https://github.<corp>.com/<org>/<repo>.git" bash /path/to/journals/skills/github-public-private-workflow/scripts/git-dual-remote-setup.sh
```

---

## Daily commands (agent-safe)

### Pull latest public OSS (`upstream/main`)

```bash
git pub-pull
```

### Pull latest private/internal (`origin/main`)

```bash
git priv-pull
```

### Push (private only)

```bash
git priv-push
```

### Switch between “mains”

```bash
git switch public-main
git switch private-main
```

### Confirm push safety

```bash
git where
```

You should see `upstream` push URL set to `DISABLED`.

---

## Syncing public changes into private

Typical flow:

```bash
git pub-pull
git switch private-main
git merge public-main
```

If you prefer rebase:

```bash
git pub-pull
git switch private-main
git rebase public-main
```

Then push only to private:

```bash
git priv-push
```

---

## Rules for coding agents (Cline, etc.)

- **Never push to `upstream`**.
- **Only push to `origin`**.
- Prefer working from `**private-main**` for any changes that will be pushed.
- Treat public GitHub as **read-only** in this clone.
- Before pushing, run `git where` and confirm `upstream` push URL is `DISABLED`.
- Where policy allows, run `install-global-github-push-block.sh` (see [Global enforcement](#global-enforcement-block-accidental-githubcom-pushes)); do not use `--no-verify` to bypass safety hooks unless explicitly instructed.

## Examples (copy/paste)

### Sync latest OSS changes into private and push

```bash
git pub-pull
git switch private-main
git merge public-main
git priv-push
```

### Sanity-check remotes before pushing

```bash
git where
```

