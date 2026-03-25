# Path Ledger

> Record stable environment facts here. This is the single source of truth for runtime paths, endpoints, and deployment-related access.

## Environment Addresses

| Environment | Address | Notes |
|-------------|---------|-------|
| local | `http://localhost:3000` | |
| staging | `https://staging.example.com` | replace with the real staging address |
| production | `https://www.example.com` | replace with the real production address |

## Server Paths

| Item | Path |
|------|------|
| deploy root | `/var/www/project` |
| log directory | `/var/log/project` |
| config file | `/etc/project/config.json` |
| data directory | `/var/data/project` |
| backup directory | `/var/backups/project` |

## Runtime and Observation Entry Points

| Name | Type | Start | Observe | Purpose |
|------|------|-------|---------|---------|
| web-ui | browser_console | `pnpm dev` / `npm run dev` | browser console / Playwright console | frontend interaction |
| gui-executor | browser_console / network_trace | `npx playwright test --headed` | visible browser / trace / GUI logs | GUI validation loop |
| api-server | process_stdout | `pnpm dev:api` / `uvicorn ...` | terminal output | backend request handling |
| worker-log | app_log_file | - | `tail -f logs/worker.log` | async jobs |
| api-trace | network_trace | `curl` / browser / Playwright | network panel | request/response debugging |
| test-runner | test_runner_output | `pnpm test` / `pytest -q` | command output | automated testing |

## GUI Validation Defaults

| Item | Value |
|------|-------|
| default executor | `Playwright` |
| headed command | `npx playwright test --headed` |
| trace / screenshot path | `.autodev/temp/gui/` / `playwright-report/` |
| test account | fill when available |

## Git Facts

| Item | Value |
|------|-------|
| origin | `git@github.com:owner/repo.git` |
| integration branch | `main` |
| protected branches | `main, master, production, release/*` |
| integration mode | `merge_allowed` |
| push default | `false` |

## Database

| Item | Value |
|------|-------|
| type | SQLite / MySQL / PostgreSQL |
| local path | `./data/database.db` |
| production path | `/var/data/project/database.db` |
| backup path | `/var/backups/project/db/` |

## path.md Update Rule

- record long-lived facts only, not temporary session values
- compare against the current file before writing
- add missing facts, update changed facts, skip unchanged facts
- temporary addresses or one-off values stay in the conversation only
