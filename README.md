# brain2

Second-brain system for Obsidian vaults. Frontmatter standard + 2 scripts + Claude Code skill glue. Built to let an LLM search your notes cheap — index table first, raw files only when matched.

## Problem it solves

Vault grows. Grep-everything search burns context, slow, noisy. This gives every note structured metadata (tags/keywords/summary) and rolls it into one index table. Search = read index table (cheap) → open only matched files (expensive, rare).

## Files

| File | What |
|---|---|
| `FRONTMATTER.md` | Frontmatter spec — tag categories, naming convention, full example |
| `obsidian-frontmatter-template.md` | Placeholder frontmatter block, prepended to notes missing one |
| `obsidian-index-frontmatter-template.md` | Same, for `_index_.md` folder-index files |
| `obsidian-frontmatter.sh` | Scans vault, adds placeholder frontmatter to notes missing it. Dry-run default |
| `obsidian-index.sh` | Rebuilds index table in `OBSIDIAN.md` from all notes' frontmatter |

## Setup

1. Vault root needs numbered top-level folders: `1_ENG/`, `2_LAB/`, etc. Scripts only scan these.
2. Set `VAULT_DIR` in both `.sh` scripts to your vault path.
3. Vault root needs `OBSIDIAN.md` with index markers:
   ```
   <!-- INDEX:START -->
   <!-- INDEX:END -->
   ```
4. Read `FRONTMATTER.md`, define your own folder naming convention (marked REDACTED — mine's SUSE/Rancher-specific).

## Frontmatter format

```yaml
---
tags: [active, no-action, guide, kubernetes]
keywords: kubectl, deployment, scale, exec
summary: "One sentence describing the note"
---
```

4 tag categories, 1 pick each minimum: STATUS, ACTION, DOC_TYPE, AREA. Full rules in `FRONTMATTER.md`.

## Workflow

```
obsidian-frontmatter.sh          # dry-run, see what's missing frontmatter
obsidian-frontmatter.sh --run    # apply placeholder frontmatter
obsidian-index.sh                # rebuild OBSIDIAN.md index table
```

Files already carrying frontmatter get skipped — safe to rerun anytime. New note without frontmatter → gets a `[to-review]` placeholder → you fill in real tags/keywords/summary → rerun index script.

## Claude Code integration

Point `OBSIDIAN.md` at the top of your Claude Code project instructions (CLAUDE.md, or a `/vault` skill). Tell it:

1. Run `obsidian-frontmatter.sh` first, dry-run, report count.
2. Run `obsidian-index.sh` to refresh the table.
3. Read `OBSIDIAN.md`, use tiered retrieval: match query → index table tags/keywords → 1-2 hits open directly, 3+ hits read `summary` field first, narrow, then open.
4. Never grep raw notes before checking the index.

That's the whole trick — cheap index scan before expensive file reads.

## Naming convention

- Folders: `ALL_CAPS_WITH_UNDERSCORE`, numbered prefix top-level (`1_ENG`, `2_LAB`)
- Files: `PascalCase.md`
- Folder index/MOC file: exactly `_index_.md`, lowercase, frontmatter = `tags: [index]` only
- Never-load folders: prefix `_` (`_BOOKS`, `_JOURNAL`, `_FILES`) — backups/dumps, skipped by both scripts

`obsidian-frontmatter.sh` lints naming on every run, warns (doesn't block) on violations.
