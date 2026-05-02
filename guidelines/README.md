# Guidelines

Single home for project-agnostic engineering guidelines pulled out of individual repos. Edit here, and every linked project sees the change.

## Files


| File                                                   | One-liner                                                                                                                  | Originated in  |
| ------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------- | -------------- |
| [bottom-bar-guidelines.md](./bottom-bar-guidelines.md) | Fixed bottom status bar pattern for SPAs (env, API health, version, links) — matches LENS `BottomBar.jsx` + `Layout.jsx`.  | lens-rag       |
| [docker-lab-guidelines.md](./docker-lab-guidelines.md) | Predictable Docker Compose workflow for lab environments: dev/prod profiles, proxy args, single-origin browser traffic.    | lens-rag       |
| [excel-guidelines.md](./excel-guidelines.md)           | Reliable Excel ingest/export for RAG/ETL pipelines: text-first reads, merged-cell handling, pitfalls.                      | lens-rag       |
| [github-guidelines.md](./github-guidelines.md)         | Safe git workflow when you have a public OSS upstream and a private origin mirror; scripts live under [`skills/github-public-private-workflow/`](../skills/github-public-private-workflow/). | lens-ragas-web |
| [ollama-guidelines.md](./ollama-guidelines.md)         | Guardrails for Ollama from Dockerized backends: base URL normalization, the localhost-in-container trap, preflight checks. | lens-ragas-web |


## How this folder is used

- This folder is the **source of truth**. Edit files here.
- Each origin project has a `guidelines/` symlink pointing back here, so the files are still reachable from inside the repo:

```
lens-rag/guidelines        -> ../journals/guidelines
lens-ragas-web/guidelines  -> ../journals/guidelines
```

- The symlinks are **relative**, so moving `/Users/hanifm/work` somewhere else won't break them.

## Conventions

- Filenames: lowercase **kebab-case**, suffixed `-guidelines.md`.
- Several files use YAML front matter (`name`, `description`, `applies_to`, `rules`) so they double as **agent-loadable skills** in Cursor / Claude Code.
- Keep one topic per file. If a guideline grows past ~3 distinct subjects, split it.

## Adding a new one

1. Drop the new `.md` into this folder using the kebab-case naming.
2. Add a row to the table above.
3. If the guideline originated in a specific project, the existing `guidelines/` symlink already exposes it there — nothing else to wire up.
4. If a *new* project should see this folder, add a symlink:

```bash
ln -s ../journals/guidelines /Users/hanifm/work/<project>/guidelines
```

## Removing one

1. `rm` the file here.
2. Drop its row from the table.
3. The symlinks stay valid — they point at the folder, not individual files.

