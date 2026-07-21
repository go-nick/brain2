# Vault Frontmatter Standard

Every `.md` note in this vault must have a frontmatter block as the first lines.

---

## Format

```yaml
---
tags: [STATUS, ACTION, DOC_TYPE, AREA]
keywords: term1, term2, term3, ...
summary: "One sentence describing what this note contains"
---
```

**Rules:**
- Minimum 4 tags: one per category (STATUS, ACTION, DOC_TYPE, AREA)
- Extra tags allowed only for AREA
- `summary` always in double quotes, one sentence max
- `keywords` comma-separated, no limit — include terms you would naturally search for
- Script uses `awk` to extract frontmatter between first `---` pair at line 1 — no line limit
- No multi-line values — `summary` and `keywords` must stay on a single line each
- No YAML block scalars (`|` or `>`) allowed

---

## Tag Categories

### STATUS — lifecycle state of the document (pick 1)

| Tag | Meaning |
|-----|---------|
| `active` | Currently relevant and in use |
| `draft` | Work in progress, not complete |
| `completed` | Done, no further action needed |
| `old` | Outdated, kept for historical reference |

---

### ACTION — what attention this note needs (pick 1)

| Tag           | Meaning                         |
| ------------- | ------------------------------- |
| `to-review`   | Needs review or decision        |
| `no-action`   | Reference only, nothing pending |

---

### DOC_TYPE — type of document (pick 1)

| Tag         | Meaning                                     |
| ----------- | ------------------------------------------- |
| `design`    | Architecture or system design doc           |
| `process`   | Runbook, workflow, or how-to                |
| `reference` | Lookup table, cheatsheet, config reference  |
| `tracking`  | Status tracking, release tracking, progress |
| `guide`     | Tutorial or setup guide                     |
| `no-type`   | Does not fit any category above             |
| `index`     | Folder index / MOC — pointer file only, no content of its own |
| `template`  | Blank, fill-in-the-blank doc meant to be copied per new project |

---

### AREA — domain or technology (pick 1 minimum, more allowed)

| Tag | Meaning |
|-----|---------|
| `helm-charts` | Helm chart development |
| `rancher-charts` | rancher/charts repo specifics |
| `kubernetes` | Kubernetes concepts and tooling |
| `golang` | Go language and tooling |
| `github-actions` | GHA workflows and CI/CD |
| `infra` | Infrastructure as code, cloud providers (Terraform, AWS, etc.) |
| `project-management` | Client project scoping, estimation, freelance process |
| `homelab` | Home lab infrastructure |
| `dev-tooling` | Personal dev environment setup (CLI tools, shell, editor, auth) |
| `career` | Career growth, resumes, jobs |
| `bitcoin` | Bitcoin research and investment |
| `finance` | Personal finance (non-bitcoin) |
| `personal` | Personal notes, journal, life |

---

## Naming Convention

### Folders

**REDACTED - define your own**

**Never load folders prefixed with `_`** — `_BOOKS`, `_FILES`, `_JOURNAL`, `_PDF`. Backups/huge dumps, out of scope for retrieval.

### Files
PascalCase — e.g. `SomethingWeird.md`. No underscores, hyphens, spaces, or ALL_CAPS.

**Exception — folder index files:** always named exactly `_index_.md`, lowercase, regardless of which folder it lives in. One per folder that needs a defined reading order (opt-in, not mandatory everywhere). Matches the `Folder Index` Obsidian community plugin's convention, in case it's adopted later. Not a "never-load" folder-skip signal despite the leading underscore — that rule applies to folders only; `_index_.md` is a file and must always be loaded first when present.

**No numeric prefixes on regular files.** Reading order lives in `_index_.md` (as an ordered list/links), not encoded in filenames. `0_Mission.md` → `Mission.md`; the index file states the order instead.

**Frontmatter for `_index_.md` files:** `tags: [index]` only — no STATUS, ACTION, DOC_TYPE, or AREA tags, no `keywords`, no `summary`. Index files point to other notes, they hold no content of their own — nothing to summarize or tag beyond marking them as an index.

```yaml
---
tags: [index]
---
```

---

## Full Example

```yaml
---
tags: [active, no-action, design, helm-charts, rancher-charts, github-actions]
keywords: release tracker, chart families, helm-charts, QA, UnRC, Released, automation-core, kubernetes, helm, release-engineering, release, engineering.
summary: "YAML-based chart release tracking system in automation-core replacing Confluence Tables"
---
```

---

