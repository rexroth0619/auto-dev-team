# Changelog

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
