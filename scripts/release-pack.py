#!/usr/bin/env python3

from __future__ import annotations

import argparse
import json
import re
import subprocess
from collections import Counter, defaultdict
from datetime import datetime
from pathlib import Path
from typing import Dict, Iterable, List, Sequence, Tuple


DOMAIN_RULES = {
    "ui": {
        "segments": {"ui", "page", "pages", "view", "views", "component", "components", "frontend", "web"},
        "suffixes": {".js", ".jsx", ".ts", ".tsx", ".vue", ".css", ".scss", ".less", ".html"},
        "label": "UI / GUI",
    },
    "api": {
        "segments": {"api", "apis", "controller", "controllers", "route", "routes", "handler", "handlers"},
        "suffixes": {".js", ".jsx", ".ts", ".tsx", ".py", ".go"},
        "label": "API / Controller",
    },
    "service": {
        "segments": {"service", "services", "usecase", "usecases", "workflow", "logic", "domain"},
        "suffixes": {".js", ".jsx", ".ts", ".tsx", ".py", ".go"},
        "label": "Service / Domain",
    },
    "data": {
        "segments": {
            "repo",
            "repos",
            "repository",
            "repositories",
            "dao",
            "daos",
            "mapper",
            "mappers",
            "model",
            "models",
            "entity",
            "entities",
            "migration",
            "migrations",
            "sql",
            "db",
            "database",
            "store",
            "stores",
        },
        "suffixes": {".sql", ".py", ".go", ".ts", ".tsx", ".js", ".jsx"},
        "label": "Data / DB",
    },
    "config": {
        "segments": {"config", "configs", "env", "settings"},
        "suffixes": {".json", ".yaml", ".yml", ".toml", ".ini", ".env"},
        "label": "Config",
    },
    "docs": {
        "segments": {"docs", "references", "assets"},
        "suffixes": {".md"},
        "label": "Docs",
    },
    "tests": {
        "segments": {"test", "tests", "__tests__", "spec"},
        "suffixes": {".spec.ts", ".test.ts", ".spec.js", ".test.js", ".spec.py", ".test.py"},
        "label": "Tests",
    },
}

ENTITY_STOPWORDS = {
    "src",
    "app",
    "lib",
    "core",
    "common",
    "shared",
    "service",
    "services",
    "controller",
    "controllers",
    "route",
    "routes",
    "handler",
    "handlers",
    "model",
    "models",
    "entity",
    "entities",
    "repository",
    "repositories",
    "repo",
    "dao",
    "db",
    "database",
    "migration",
    "migrations",
    "index",
    "utils",
    "util",
    "helper",
    "helpers",
    "page",
    "pages",
    "view",
    "views",
    "component",
    "components",
    "test",
    "tests",
    "spec",
    "mock",
    "mocks",
    "config",
    "configs",
    "readme",
    "references",
    "assets",
    "template",
    "templates",
    "skill",
    "skills",
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Generate an interactive pre-release testing session draft from recent git commits."
    )
    group = parser.add_mutually_exclusive_group()
    group.add_argument("--range", default="", help="Explicit git commit range, e.g. abc123..def456.")
    group.add_argument("--commit", default="", help="Single commit to inspect. Defaults to HEAD.")
    group.add_argument(
        "--commits",
        type=int,
        default=1,
        help="Use the latest N commits when --range/--commit is not provided. Default: 1.",
    )
    parser.add_argument("--task", default="", help="Short task description for the output header.")
    parser.add_argument("--env", default="staging", help="Environment label. Default: staging.")
    parser.add_argument(
        "--output",
        default=".autodev/temp/release-test-pack.md",
        help="Markdown output path relative to repo root.",
    )
    parser.add_argument(
        "--json",
        default="",
        help="Optional JSON summary path relative to repo root.",
    )
    parser.add_argument(
        "--stdout",
        action="store_true",
        help="Also print the generated markdown to stdout.",
    )
    return parser.parse_args()


def run_cmd(command: Sequence[str], cwd: Path) -> str:
    proc = subprocess.run(
        command,
        cwd=str(cwd),
        check=False,
        capture_output=True,
        text=True,
    )
    if proc.returncode != 0:
        raise RuntimeError(proc.stderr.strip() or "command failed")
    return proc.stdout.strip()


def get_repo_root() -> Path:
    return Path(run_cmd(["git", "rev-parse", "--show-toplevel"], Path.cwd())).resolve()


def resolve_target(args: argparse.Namespace) -> Tuple[str, bool]:
    if args.range:
        return args.range, True
    if args.commit:
        return args.commit, False
    if args.commits <= 1:
        return "HEAD", False
    return f"HEAD~{args.commits}..HEAD", True


def get_commit_rows(repo_root: Path, target: str, is_range: bool) -> List[Tuple[str, str]]:
    if is_range:
        raw = run_cmd(["git", "log", "--reverse", "--format=%H%x09%s", target], repo_root)
    else:
        raw = run_cmd(["git", "show", "-s", "--format=%H%x09%s", target], repo_root)
    rows: List[Tuple[str, str]] = []
    for line in raw.splitlines():
        if not line.strip():
            continue
        commit_hash, _, subject = line.partition("\t")
        rows.append((commit_hash.strip(), subject.strip()))
    return rows


def get_changed_files(repo_root: Path, target: str, is_range: bool) -> List[Tuple[str, str]]:
    if is_range:
        raw = run_cmd(["git", "diff", "--name-status", target], repo_root)
    else:
        raw = run_cmd(["git", "show", "--name-status", "--format=", target], repo_root)
    rows: List[Tuple[str, str]] = []
    for line in raw.splitlines():
        if not line.strip():
            continue
        status, _, path = line.partition("\t")
        if path.strip():
            rows.append((status.strip(), path.strip()))
    return rows


def detect_domains(path_text: str) -> List[str]:
    path = Path(path_text)
    segments = {part.lower() for part in path.parts}
    suffix = path.suffix.lower()
    stem = path.name.lower()
    matched: List[str] = []
    for key, rule in DOMAIN_RULES.items():
        if segments & rule["segments"]:
            matched.append(key)
            continue
        if suffix in rule["suffixes"] or stem in rule["suffixes"]:
            matched.append(key)
    if not matched:
        matched.append("service")
    return matched


def extract_entities(paths: Iterable[str]) -> List[str]:
    counter: Counter[str] = Counter()
    for path_text in paths:
        path = Path(path_text)
        tokens = re.split(r"[^a-zA-Z0-9]+", "/".join(path.parts))
        for token in tokens:
            lowered = token.lower()
            if len(lowered) < 3:
                continue
            if lowered.isdigit() or lowered in ENTITY_STOPWORDS:
                continue
            counter[lowered] += 1
    return [token for token, _ in counter.most_common(3)]


def infer_need_queries(domains: Iterable[str]) -> bool:
    domain_set = set(domains)
    return bool(domain_set & {"data", "service", "api"})


def read_optional_text(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8", errors="ignore")
    except Exception:
        return ""


def detect_sql_dialect(repo_root: Path) -> Tuple[str, str]:
    candidates = [
        repo_root / ".autodev" / "path.md",
        repo_root / "docker-compose.yml",
        repo_root / "compose.yml",
        repo_root / "package.json",
        repo_root / "pyproject.toml",
        repo_root / "requirements.txt",
        repo_root / "go.mod",
        repo_root / ".env",
        repo_root / ".env.example",
        repo_root / "application.yml",
        repo_root / "application.yaml",
        repo_root / "application.properties",
    ]
    combined = "\n".join(read_optional_text(path).lower() for path in candidates if path.exists())
    if any(token in combined for token in ("postgresql", "postgres", "psycopg", "pgx", "asyncpg")):
        return "PostgreSQL", "Detected postgres-related signals from path.md or project config"
    if any(token in combined for token in ("mysql", "mariadb", "pymysql")):
        return "MySQL", "Detected mysql-related signals from path.md or project config"
    if any(token in combined for token in ("sqlite", ".db", "better-sqlite3")):
        return "SQLite", "Detected sqlite-related signals from path.md or project config"
    return "unconfirmed", "No clear database dialect was detected from path.md or common project config files"


def seven_day_filter(dialect: str) -> str:
    if dialect == "PostgreSQL":
        return "updated_at >= NOW() - INTERVAL '7 days'"
    if dialect == "MySQL":
        return "updated_at >= NOW() - INTERVAL 7 DAY"
    if dialect == "SQLite":
        return "updated_at >= DATETIME('now', '-7 days')"
    return "updated_at >= <replace with the correct last-7-days condition for your actual database dialect>"


def make_query_templates(entities: List[str], domains: Iterable[str], dialect: str) -> List[Dict[str, str]]:
    domain_set = set(domains)
    if not infer_need_queries(domain_set):
        return []

    entity = entities[0] if entities else "core"
    table_placeholder = f"<{entity}_table>"
    base_fields = "id, status, updated_at"
    queries = [
        {
            "id": "Q1",
            "purpose": f"find recent candidate records for validating the {entity}-related change",
            "sql": f"SELECT {base_fields}\nFROM {table_placeholder}\nORDER BY updated_at DESC\nLIMIT 20;",
            "usage": "confirm that staging already has recent sample records that can be used directly for manual validation.",
        },
        {
            "id": "Q2",
            "purpose": f"check the state distribution of {entity} records so boundary cases can be chosen deliberately",
            "sql": f"SELECT status, COUNT(*) AS cnt\nFROM {table_placeholder}\nGROUP BY status\nORDER BY cnt DESC;",
            "usage": "decide which states should drive happy-path, negative, and boundary coverage first.",
        },
        {
            "id": "Q3",
            "purpose": f"review one week of {entity} changes and select records closer to the real production path",
            "sql": (
                f"SELECT {base_fields}\nFROM {table_placeholder}\n"
                f"WHERE {seven_day_filter(dialect)}\n"
                "ORDER BY updated_at DESC\nLIMIT 50;"
            ),
            "usage": "prefer recently active records so the test does not rely on stale or dirty data.",
        },
    ]
    if {"ui", "api"} & domain_set:
        queries.append(
            {
                "id": "Q4",
                "purpose": f"fetch one precise {entity} record that can drive direct detail-page or list-page verification",
                "sql": f"SELECT {base_fields}\nFROM {table_placeholder}\nWHERE id = <REPLACE_WITH_ID>;",
                "usage": "use this when the UI flow requires a specific ID or document number to be pasted directly.",
            }
        )
    return queries


def make_test_data_rows(entities: List[str], domains: Iterable[str]) -> List[Dict[str, str]]:
    domain_labels = ", ".join(DOMAIN_RULES[key]["label"] for key in sorted(set(domains)) if key in DOMAIN_RULES)
    rows: List[Dict[str, str]] = []
    seeds = entities or ["core object"]
    for index, entity in enumerate(seeds[:3], start=1):
        rows.append(
            {
                "id": f"TD-{index}",
                "change": f"recent commits related to {entity}",
                "purpose": f"cover the primary validation path for {entity}",
                "method": "reuse query results / create manually / generate by script",
                "fields": f"at minimum confirm `{entity}_id / status / updated_at`, then refine with {domain_labels or 'core business fields'}.",
                "expected": f"obtain a {entity} sample that can drive list, detail, or state-transition checks.",
            }
        )
    return rows


def make_use_cases(entities: List[str], domains: Iterable[str]) -> List[Dict[str, str]]:
    seeds = entities or ["core object"]
    primary = seeds[0]
    use_cases = [
        {
            "id": "UC-1",
            "title": f"{primary} primary-path validation",
            "change": f"recent commits related to {primary}",
            "preconditions": f"one searchable or directly pasteable {primary} ID / document number is available.",
            "why": "confirm that the happy path affected by the recent commits still works in staging.",
            "input": f"paste the `{primary}` ID / document number.",
            "page": f"the `{primary}` list page or the first searchable entrypoint.",
            "steps": [
                "paste the prepared ID / document number into the list page or search box.",
                "click query, search, or filter.",
                "open the detail page or trigger the button flow directly affected by the recent commits.",
            ],
            "expected": "page state, button visibility, field rendering, or submission result match the intended recent behavior change.",
            "success": "the main path touched by the recent commits still works in staging.",
            "failure": "no data found, wrong state, missing button, API error, or incorrect UI prompt.",
        },
        {
            "id": "UC-2",
            "title": f"{primary} boundary or negative validation",
            "change": f"recent commits related to {primary}",
            "preconditions": f"a second {primary} sample exists with a different state or incomplete field set.",
            "why": "cover the boundary or negative path closest to the recent change instead of testing only the happy path.",
            "input": f"paste the boundary-state `{primary}` ID / document number.",
            "page": f"the `{primary}` list page, detail page, or the dialog most closely tied to this change.",
            "steps": [
                "open the page or dialog directly affected by the recent commits.",
                "enter the boundary-state sample and trigger the query or action.",
                "observe prompts, button state, and the final result.",
            ],
            "expected": "error prompts, disabled states, or fallback logic behave correctly and do not allow unintended success.",
            "success": "the recent commits did not break edge or failure behavior.",
            "failure": "missing error prompts, unintended success, broken UI state, or inconsistent data rendering.",
        },
        {
            "id": "UC-3",
            "title": "regression observation",
            "change": "older paths adjacent to the recent commits",
            "preconditions": "a historical sample is ready for a path that should still work.",
            "why": "verify that the recent commits did not accidentally damage the previous path or legacy-state data.",
            "input": "paste the historical sample ID / document number.",
            "page": "the same entry page used by the main path.",
            "steps": [
                "search for the historical sample.",
                "repeat the action that should still work from the previous version.",
                "compare the page state with the expected legacy-path behavior.",
            ],
            "expected": "the legacy path still works as before and does not trigger the new logic incorrectly.",
            "success": "the recent commits stayed relatively contained and did not create an obvious regression.",
            "failure": "legacy data is blocked by new logic, page copy is wrong, or state mapping is broken.",
        },
    ]
    if "ui" not in set(domains):
        for case in use_cases:
            case["page"] = "the business page or console entrypoint that triggers this path."
    return use_cases


def render_markdown(
    *,
    task: str,
    env_label: str,
    target: str,
    commits: List[Tuple[str, str]],
    changed_files: List[Tuple[str, str]],
    domains: List[str],
    entities: List[str],
    dialect: str,
    dialect_reason: str,
    queries: List[Dict[str, str]],
    test_data_rows: List[Dict[str, str]],
    use_cases: List[Dict[str, str]],
) -> str:
    created_at = datetime.now().strftime("%Y-%m-%d %H:%M")
    commit_summary = f"{commits[0][0][:7]} - {commits[0][1]}" if commits else "N/A"
    behavior_lines = [f"- `{commit_hash[:7]}` {subject}" for commit_hash, subject in commits] or ["- none"]
    changed_file_lines = [f"- `{status}` `{path}`" for status, path in changed_files] or ["- none"]
    domain_lines = [
        f"- {DOMAIN_RULES[key]['label']}" for key in sorted(set(domains)) if key in DOMAIN_RULES
    ] or ["- not identified; fill manually if needed"]
    entity_text = ", ".join(entities) if entities else "the core object touched by the recent commits"
    need_queries = "real data required first" if queries else "can draft without querying first"
    task_text = task or "organize an interactive staging validation flow from recent commits"

    lines: List[str] = [
        "# Interactive Release-Test Draft",
        "",
        f"Created: {created_at}",
        f"Task: {task_text}",
        f"Commit range: `{target}`",
        f"Environment: {env_label}",
        "",
        "> Use this only as the current-round agent draft. It is not the default final artifact sent directly to the user.",
        "",
        f"## 🛠️ Release Test Start {{{commit_summary}}}",
        "",
        f"- Current commit scope: `{target}`",
        f"- One-line summary: prioritize staging validation around `{entity_text}`.",
        "- Why this first: these files are closest to the recent behavior change and most likely to expose regressions in staging.",
        "",
        "## Behavior Changes From Recent Commits",
        "",
        *behavior_lines,
        "",
        "### Changed Files",
        "",
        *changed_file_lines,
        "",
        "### Inferred Impact Areas",
        "",
        *domain_lines,
        "",
        "## Need Real Data First?",
        "",
        f"- Conclusion: {need_queries}",
        "- Reason: "
        + (
            "The recent commits touch API / service / data paths, so real staging samples should be selected first."
            if queries
            else "The recent commits are mostly UI or docs-oriented, so a manual test draft can start without querying first."
        ),
        "",
        "## 🛠️ Bootstrap Database Queries",
        "",
        "> Send the SQL below to the user for execution in staging, then continue after they paste the results back.",
        "",
    ]

    if queries:
        lines.extend(
            [
                f"- Inferred database dialect: {dialect}",
                f"- Reason for that guess: {dialect_reason}",
                "",
                "```sql",
            ]
        )
        for query in queries:
            lines.extend(
                [
                    f"-- {query['id']}: {query['purpose']}",
                    query["sql"],
                    "",
                ]
            )
        lines.extend(["```", ""])
        for query in queries:
            lines.extend(
                [
                    f"- `{query['id']}` {query['purpose']}",
                    f"  How the result will be used: {query['usage']}",
                ]
            )
        lines.extend(
            [
                f"- Note: generated in {dialect} syntax. If that is not the real project dialect, rewrite the full block before execution.",
                "",
            ]
        )
    else:
        lines.extend(
            [
                "- Querying is not forced in this round. Add a focused query later if page paths or state transitions remain unclear.",
                "",
            ]
        )

    lines.extend(
        [
            "## ⏸️ Waiting For Staging Query Results",
            "",
            "- Ask the user to paste the full query result back.",
            "- Do not continue to final test data, use cases, or manual steps before results return.",
            "",
        ]
    )

    if not queries:
        lines.extend(
            [
                "## 🛠️ Draft Test Data",
                "",
            ]
        )
        for row in test_data_rows:
            lines.extend(
                [
                    f"### {row['id']}",
                    "",
                    f"- Related change: {row['change']}",
                    f"- Purpose: {row['purpose']}",
                    f"- Creation method: {row['method']}",
                    f"- Key fields: {row['fields']}",
                    f"- Expected sample: {row['expected']}",
                    "",
                ]
            )

        lines.extend(
            [
                "## 🛠️ Testable Use Cases",
                "",
            ]
        )
        for case in use_cases:
            lines.extend(
                [
                    f"### {case['id']} {case['title']}",
                    "",
                    f"- Related change: {case['change']}",
                    f"- Preconditions: {case['preconditions']}",
                    f"- Why test this: {case['why']}",
                    "",
                ]
            )

        lines.extend(
            [
                "## 🛠️ Manual Steps For Staging",
                "",
            ]
        )
        for case in use_cases:
            lines.extend(
                [
                    f"### {case['id']} {case['title']}",
                    "",
                    f"- Input: {case['input']}",
                    f"- Open page: {case['page']}",
                    "- Steps:",
                    *[f"  {index}. {step}" for index, step in enumerate(case["steps"], start=1)],
                    f"- Expected result: {case['expected']}",
                    f"- Success signal: {case['success']}",
                    f"- Failure signal: {case['failure']}",
                    "",
                ]
            )

    lines.extend(
        [
            "## ⚠️ Open Questions And Residual Risk",
            "",
            "- Open questions: fill in the real table names, status fields, page paths, and button names before final execution.",
            "- Residual risk: this script drafts from commits and paths only; final business-specific refinement is still required.",
            "",
            "## ✅ Current Round Ready",
            "",
            f"- Query count: {len(queries)}",
            f"- Test-data count: {0 if queries else len(test_data_rows)}",
            f"- Use-case count: {0 if queries else len(use_cases)}",
            "- Next move: "
            + (
                "Run the SQL first, then paste the results back so the agent can tighten them into concrete IDs, page paths, and click actions."
                if queries
                else "Continue refining the draft with real page names, button names, and business objects, then wait for the user to run the manual staging cases."
            ),
            "",
        ]
    )
    return "\n".join(lines)


def build_summary(
    *,
    target: str,
    commits: List[Tuple[str, str]],
    changed_files: List[Tuple[str, str]],
    domains: List[str],
    entities: List[str],
    queries: List[Dict[str, str]],
) -> Dict[str, object]:
    grouped: Dict[str, List[str]] = defaultdict(list)
    for status, path in changed_files:
        grouped[status].append(path)
    return {
        "target": target,
        "commits": [{"hash": commit_hash, "subject": subject} for commit_hash, subject in commits],
        "changed_files": grouped,
        "domains": sorted(set(domains)),
        "entities": entities,
        "needs_queries": bool(queries),
        "query_count": len(queries),
    }


def write_text(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")


def normalize_entities(entities: List[str], domains: Iterable[str]) -> List[str]:
    domain_set = set(domains)
    if domain_set and domain_set <= {"docs", "tests", "config"}:
        return []
    return entities


def main() -> int:
    args = parse_args()
    repo_root = get_repo_root()
    target, is_range = resolve_target(args)
    commits = get_commit_rows(repo_root, target, is_range)
    changed_files = get_changed_files(repo_root, target, is_range)
    file_paths = [path for _, path in changed_files]
    all_domains = [domain for path in file_paths for domain in detect_domains(path)]
    entities = normalize_entities(extract_entities(file_paths), all_domains)
    dialect, dialect_reason = detect_sql_dialect(repo_root)
    queries = make_query_templates(entities, all_domains, dialect)
    test_data_rows = make_test_data_rows(entities, all_domains)
    use_cases = make_use_cases(entities, all_domains)
    markdown = render_markdown(
        task=args.task,
        env_label=args.env,
        target=target,
        commits=commits,
        changed_files=changed_files,
        domains=all_domains,
        entities=entities,
        dialect=dialect,
        dialect_reason=dialect_reason,
        queries=queries,
        test_data_rows=test_data_rows,
        use_cases=use_cases,
    )

    output_path = (repo_root / args.output).resolve() if not Path(args.output).is_absolute() else Path(args.output)
    write_text(output_path, markdown + "\n")

    if args.json:
        summary = build_summary(
            target=target,
            commits=commits,
            changed_files=changed_files,
            domains=all_domains,
            entities=entities,
            queries=queries,
        )
        json_path = (repo_root / args.json).resolve() if not Path(args.json).is_absolute() else Path(args.json)
        write_text(json_path, json.dumps(summary, ensure_ascii=False, indent=2) + "\n")

    print(f"🛠️ release-pack generated: {output_path.relative_to(repo_root)}")
    if args.json:
        json_path = (repo_root / args.json).resolve() if not Path(args.json).is_absolute() else Path(args.json)
        print(f"JSON written to: {json_path.relative_to(repo_root)}")
    if args.stdout:
        print()
        print(markdown)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
