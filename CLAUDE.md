# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A personal knowledge base and skill registry. It has two distinct areas:

- **`guidelines/`** — project-agnostic engineering guidelines, written as Markdown with YAML front matter so they double as agent-loadable skills in Cursor / Claude Code.
- **`skills/`** — versioned agent skills that ship with runnable scripts or other assets alongside a `SKILL.md`.

Other projects (e.g. `lens-rag`, `lens-ragas-web`) symlink their `guidelines/` directory here, so this folder is the authoritative source of truth for all shared guidelines.

## Conventions

### Guidelines (`guidelines/`)

- Filename: lowercase **kebab-case**, suffixed `-guidelines.md`.
- Each file begins with YAML front matter (`name`, `description`, `applies_to`, `rules`) so it can be loaded as an agent skill.
- One topic per file. Split if a file grows past ~3 distinct subjects.
- After adding a file, add a row to the table in `guidelines/README.md`.

### Skills (`skills/`)

- Each skill lives in its own subdirectory with a `SKILL.md` at the root.
- `SKILL.md` uses YAML front matter (`name`, `description`) and documents usage, daily commands, and rules for coding agents.
- Scripts live under `scripts/` within the skill directory.
- After adding a skill, add a row to the table in `skills/README.md`.
- Do **not** duplicate a topic in both `guidelines/` and `skills/`; use `skills/` when the topic ships scripts.

### Linking a new project to shared guidelines

```bash
ln -s ../journals/guidelines /Users/hanifm/work/<project>/guidelines
```

Use relative paths — this keeps symlinks valid if the workspace moves.

## Git / push safety

This repo uses the **public upstream + private origin** workflow documented in [`skills/github-public-private-workflow/SKILL.md`](skills/github-public-private-workflow/SKILL.md).

Key rules:
- `upstream` is **fetch-only** (`push URL = DISABLED`).
- Only push to `origin` (private/internal host).
- Run `git where` before any push to confirm remote targets.
- Work on `private-main` or branches created from it; never push to `public-main`.

Daily aliases set up by the skill:

| Action | Command |
|--------|---------|
| Pull from public upstream | `git pub-pull` |
| Pull from private origin | `git priv-pull` |
| Push to private origin | `git priv-push` |
| Show remotes | `git where` |

## What to ignore

`plan.md` is gitignored — it is a scratch planning artifact, not a committed deliverable.
