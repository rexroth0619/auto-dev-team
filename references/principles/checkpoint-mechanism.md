# Checkpoint Mechanism

> Canonical version-protection protocol.

## Three Layers

- 🎯 milestone: trusted anchor
- 💿 snapshot gate: pre-write protection
- 💾 archive: validated step history

## Required Commands

- branch guard: `scripts/checkpoint.sh ensure-branch <task-slug>`
- milestone: `scripts/checkpoint.sh milestone "<fingerprint>" "<description>" <task-slug>`
- snapshot gate: `scripts/checkpoint.sh snapshot-gate <task>`
- archive: `scripts/checkpoint.sh archive "<fingerprint>" <type> "<description>"`
- list: `scripts/checkpoint.sh list`
- rollback: `scripts/checkpoint.sh rollback <hash>`

## Hard Rule

No file write may happen before the snapshot gate outputs either:
- `💿 Protected`
- `💿 Gate passed`
