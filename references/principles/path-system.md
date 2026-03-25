# Path Ledger System (`path.md`)

> `.autodev/path.md` is the single source of truth for environment addresses, runtime paths, deployment facts, log paths, and git environment facts.

## Must Contain

- environment URLs
- server paths
- runtime and observation entrypoints
- GUI executor facts
- git facts
- database facts
- third-party control planes when relevant

## Read First When The Task Touches

- git
- deployment
- paths
- environments
- logs
- consoles or observation entrypoints
- GUI executor entrypoints
- databases
- server-side config

## Update Rule

- record long-lived facts only
- compare before writing
- add missing facts
- update changed facts
- skip unchanged facts
- keep one-off temporary values in the conversation only
