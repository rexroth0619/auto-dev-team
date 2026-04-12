# Changelog

## 1.1.1

### Added

- `Brainstorm`, `Resume`, `current-brainstorm.md`, `current-flow.json`, and `current-metaphor.md`
- the current-artifact contract, `scripts/flowctl.sh`, `brainstorm-review`, and `quality-review`
- the metaphor layer with standard restaurant / logistics / factory mappings
- `.autodev/ai-sot.json`, `release-plan.schema.json`, and release auth-bridge / auto-run helpers
- the automated staging-validation loop and related selftests

### Changed

- recommended primary paths now include `Resume` for interruption recovery
- `current-*` templates now carry flow metadata and can be managed as active-flow artifacts
- Debug now requires same-pattern scanning, repair-level evaluation, and anti-regression follow-up
- Tester now generates a machine-readable `release-plan.json` before splitting into manual or automatic execution
- GUI validation now requires a visible browser window and tighter current-step coverage

### Fixed

- reduced checkpoint noise and filtered workflow-generated commits from protection output
- aligned selftests with the release automation loop

## 1.1.0

### Added

- `Brainstorm` mode and `current-brainstorm.md`
- `current-flow.json`, `flowctl.sh`, and the current-artifact contract
- `brainstorm-review` and `quality-review`
- interactive staging-validation flow
- `release-pack.py` and `release-pack-selftest.sh`
- interactive release-test draft template
- anti-spaghetti quick check before write-mode execution

### Changed

- recommended primary path is now `Brainstorm -> Architect -> Step -> Review`
- `current-*` templates are upgraded into active-flow artifacts with flow metadata
- expanded `Tester` into testing assets plus interactive validation
- added long-lived-facts update rules for `path.md`
- changed bootstrap SQL output to one complete code block in the project-appropriate database dialect
- refreshed the README with version, language branches, and Agent Quick Start

### Fixed

- fixed the working-directory issue in `blast-radius-selftest.sh`
- aligned selftests with the interactive release-testing flow
