# Mode Index

> Choose the mode first, then read exactly one mode document. Write modes must read `references/write-preflight.md` before entering the concrete flow.

## Read Order

1. Read this file first and choose the single mode.
2. If the mode writes files or changes config, run `references/write-preflight.md`.
3. Read only the matching `references/modes/*/README.md`.
4. Architect / Refactor / Optimize move into `references/modes/step/README.md` after plan approval.

## Match Rules (first match wins)

| # | Mode | Trigger | Path | Write mode |
|---|------|---------|------|------------|
| 1 | Resume | interruption recovery, model switching, “where are we”, “continue yesterday's work” | `references/modes/resume/README.md` | no |
| 2 | Hotfix | production issue, urgent outage, stop the bleeding | `references/modes/hotfix/README.md` | yes |
| 3 | Debug | bug, error, broken behavior | `references/modes/debug/README.md` | yes |
| 4 | Brainstorm | requirement discussion, boundary clarification, align before planning | `references/modes/brainstorm/README.md` | yes |
| 5 | FastTrack | tiny change, copy tweak, style tweak, single-point fix | `references/modes/fasttrack/README.md` | yes |
| 6 | Refactor | restructure, split, extract, clean architecture | `references/modes/refactor/README.md` | yes |
| 7 | Optimize | slow, performance, acceleration | `references/modes/optimize/README.md` | yes |
| 8 | Cleanup | remove dead code or redundancy | `references/modes/cleanup/README.md` | yes |
| 9 | Tester | tests, coverage, use-case validation, staging validation, test-data generation, manual test guidance | `references/modes/tester/README.md` | yes |
| 10 | Survey | learn the project, map the structure, first contact | `references/modes/survey/README.md` | no |
| 11 | Explain | explain code, flow, or architecture | `references/modes/explain/README.md` | no |
| 12 | Architect | new feature, implementation request, capability development | `references/modes/architect/README.md` | yes |

## Write Intent Fallback

If the user says things like "change this", "adjust this", or "modify X" without a clearer mode match:

- treat it as write intent
- default to **FastTrack**
- still run `references/write-preflight.md` and the pre-write snapshot gate

Do not write files before mode selection.

## Recommended Primary Paths

- interruption recovery / model switch / network loss: `Resume -> Step / Architect / Debug / Tester`
- requirement still unclear: `Brainstorm -> Architect -> Step`
- small scoped change: `FastTrack`
- clearly-scoped new feature: `Architect`
- bug fixing: `Debug`

## Progressive Disclosure Rules

- do not read multiple mode READMEs at once
- do not skip mode selection and jump straight into a mode file
- do not duplicate shared write-preflight content inside each mode doc
