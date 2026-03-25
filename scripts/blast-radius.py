#!/usr/bin/env python3

from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
from collections import defaultdict
from dataclasses import asdict, dataclass
from datetime import datetime
from pathlib import Path
from typing import Dict, Iterable, List, Optional, Sequence, Set, Tuple


SUPPORTED_SOURCE_EXTENSIONS = {
    ".js",
    ".jsx",
    ".mjs",
    ".cjs",
    ".ts",
    ".tsx",
    ".py",
    ".go",
    ".sh",
    ".bash",
    ".zsh",
}
JS_EXTENSIONS = {".js", ".jsx", ".mjs", ".cjs", ".ts", ".tsx"}
PY_EXTENSIONS = {".py"}
GO_EXTENSIONS = {".go"}
SHELL_EXTENSIONS = {".sh", ".bash", ".zsh"}
COMMON_INDEX_NAMES = {"index.js", "index.jsx", "index.ts", "index.tsx", "__init__.py"}
IGNORED_DIR_NAMES = {
    ".git",
    ".autodev",
    "node_modules",
    "dist",
    "build",
    "coverage",
    ".next",
    ".turbo",
    ".venv",
    "venv",
    "__pycache__",
}
CONFIG_PATTERNS = [
    re.compile(r"process\.env"),
    re.compile(r"import\.meta\.env"),
    re.compile(r"os\.environ"),
    re.compile(r"\bgetenv\s*\("),
    re.compile(r"\bconfig\b", re.IGNORECASE),
    re.compile(r"\bfeature[_ -]?flag\b", re.IGNORECASE),
    re.compile(r"\.env\b"),
]
DYNAMIC_PATTERNS = [
    re.compile(r"\beval\s*\("),
    re.compile(r"\bgetattr\s*\("),
    re.compile(r"\bsetattr\s*\("),
    re.compile(r"\bglobals\s*\("),
    re.compile(r"\blocals\s*\("),
    re.compile(r"\bimportlib\b"),
    re.compile(r"\b__import__\b"),
    re.compile(r"\bregister\s*\("),
    re.compile(r"\bdispatch\s*\("),
]
SYMMETRY_PAIRS = [
    ("encode", "decode"),
    ("serialize", "deserialize"),
    ("encrypt", "decrypt"),
    ("compress", "decompress"),
    ("parse", "format"),
    ("load", "save"),
    ("open", "close"),
    ("start", "stop"),
    ("lock", "unlock"),
    ("mount", "unmount"),
    ("enable", "disable"),
    ("grant", "revoke"),
    ("create", "delete"),
    ("create", "remove"),
    ("up", "down"),
]


@dataclass(frozen=True)
class Match:
    file: str
    line: int
    text: str
    kind: str
    depth: int = 0


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Generate a scriptable blast radius report before code changes."
    )
    parser.add_argument(
        "--file",
        action="append",
        default=[],
        help="Target file path relative to repo root. Can be repeated.",
    )
    parser.add_argument(
        "--symbol",
        action="append",
        default=[],
        help="Target symbol/function/class name. Can be repeated.",
    )
    parser.add_argument(
        "--target",
        action="append",
        default=[],
        help="Combined target in the form path::symbol. Can be repeated.",
    )
    parser.add_argument("--mode", default="write", help="Current skill mode.")
    parser.add_argument("--task", default="", help="Task fingerprint or short slug.")
    parser.add_argument("--step", default="", help="Step id for step-mode tasks.")
    parser.add_argument(
        "--depth",
        type=int,
        default=None,
        help="Reverse import chain depth. Defaults to config or 2.",
    )
    parser.add_argument(
        "--max-refs",
        type=int,
        default=None,
        help="Maximum rows per report section. Defaults to config or 25.",
    )
    parser.add_argument(
        "--repo-root",
        default="",
        help="Explicit repository root. Defaults to current git repo root.",
    )
    parser.add_argument(
        "--report",
        default="",
        help="Write markdown report to this path. Relative paths resolve from repo root.",
    )
    parser.add_argument(
        "--json",
        default="",
        help="Optional JSON output path. Relative paths resolve from repo root.",
    )
    parser.add_argument(
        "--write",
        action="store_true",
        help="Write report to .autodev/blast-radius/ using an auto-generated name.",
    )
    parser.add_argument(
        "--no-current",
        action="store_true",
        help="Do not update .autodev/current-blast-radius.md even if config enables it.",
    )
    parser.add_argument(
        "--quiet",
        action="store_true",
        help="Only print a concise summary to stdout.",
    )
    parser.add_argument(
        "--summary-json",
        default="",
        help="Optional path for a small machine-readable summary JSON.",
    )
    parser.add_argument(
        "--threshold-label",
        default="",
        help="Optional human-readable threshold label for startup marker context.",
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


def get_repo_root(explicit_root: str) -> Path:
    if explicit_root:
        return Path(explicit_root).resolve()
    return Path(run_cmd(["git", "rev-parse", "--show-toplevel"], Path.cwd())).resolve()


def load_config(repo_root: Path) -> dict:
    config_path = repo_root / ".autodev" / "autodev-config.json"
    if not config_path.exists():
        return {}
    try:
        return json.loads(config_path.read_text(encoding="utf-8"))
    except Exception:
        return {}


def config_get(config: dict, dotted_path: str, fallback):
    value = config
    for part in dotted_path.split("."):
        if not isinstance(value, dict) or part not in value:
            return fallback
        value = value[part]
    return value


def repo_rel(path: Path, repo_root: Path) -> str:
    return path.resolve().relative_to(repo_root).as_posix()


def normalize_repo_path(raw_path: str, repo_root: Path) -> str:
    path = Path(raw_path)
    if not path.is_absolute():
        path = (repo_root / path).resolve()
    return repo_rel(path, repo_root)


def is_binary_text(raw: bytes) -> bool:
    return b"\x00" in raw


def read_text(path: Path) -> str:
    try:
        raw = path.read_bytes()
    except Exception:
        return ""
    if is_binary_text(raw):
        return ""
    return raw.decode("utf-8", errors="ignore")


def list_repo_files(repo_root: Path) -> List[str]:
    if shutil.which("rg"):
        try:
            output = run_cmd(
                [
                    "rg",
                    "--files",
                    "-g",
                    "!.git",
                    "-g",
                    "!node_modules",
                    "-g",
                    "!dist",
                    "-g",
                    "!build",
                    "-g",
                    "!coverage",
                    "-g",
                    "!.next",
                    "-g",
                    "!.turbo",
                ],
                repo_root,
            )
            files = [line for line in output.splitlines() if line.strip()]
            if files:
                return files
        except Exception:
            pass

    files: List[str] = []
    for root, dirnames, filenames in os.walk(repo_root):
        dirnames[:] = [d for d in dirnames if d not in IGNORED_DIR_NAMES]
        root_path = Path(root)
        for name in filenames:
            rel = repo_rel(root_path / name, repo_root)
            files.append(rel)
    return sorted(files)


def list_source_files(repo_root: Path, repo_files: Sequence[str]) -> List[str]:
    return [path for path in repo_files if Path(path).suffix in SUPPORTED_SOURCE_EXTENSIONS]


def is_identifier(symbol: str) -> bool:
    return bool(re.match(r"^[A-Za-z_][A-Za-z0-9_]*$", symbol))


def is_test_file(path: str) -> bool:
    lower = path.lower()
    name = Path(lower).name
    return any(
        token in lower
        for token in (
            "/test/",
            "/tests/",
            "__tests__",
            ".test.",
            ".spec.",
        )
    ) or name.startswith("test_") or name.endswith("_test.py") or name.endswith("_test.go")


def same_path(a: str, b: str) -> bool:
    return Path(a).as_posix() == Path(b).as_posix()


def compile_symbol_patterns(symbol: str) -> List[re.Pattern[str]]:
    escaped = re.escape(symbol)
    return [
        re.compile(rf"^\s*(?:export\s+)?(?:async\s+)?function\s+{escaped}\b"),
        re.compile(rf"^\s*(?:export\s+)?(?:const|let|var)\s+{escaped}\s*="),
        re.compile(rf"^\s*(?:export\s+)?class\s+{escaped}\b"),
        re.compile(rf"^\s*(?:export\s+)?interface\s+{escaped}\b"),
        re.compile(rf"^\s*(?:export\s+)?type\s+{escaped}\b"),
        re.compile(rf"^\s*(?:export\s+)?enum\s+{escaped}\b"),
        re.compile(rf"^\s*(?:async\s+)?def\s+{escaped}\b"),
        re.compile(rf"^\s*class\s+{escaped}\b"),
        re.compile(rf"^\s*func\s+(?:\([^)]*\)\s*)?{escaped}\b"),
        re.compile(rf"^\s*(?:var|const|type)\s+{escaped}\b"),
        re.compile(rf"^\s*{escaped}\s*\(\)\s*\{{"),
        re.compile(rf"^\s*function\s+{escaped}\b"),
    ]


def find_symbol_definitions(
    symbol: str, repo_root: Path, source_files: Sequence[str], text_cache: Dict[str, str]
) -> List[Match]:
    patterns = compile_symbol_patterns(symbol)
    matches: List[Match] = []
    for rel_path in source_files:
        text = text_cache.setdefault(rel_path, read_text(repo_root / rel_path))
        if not text:
            continue
        for line_no, line in enumerate(text.splitlines(), start=1):
            if any(pattern.search(line) for pattern in patterns):
                matches.append(Match(rel_path, line_no, line.strip(), "definition"))
    return matches


def search_string_matches(
    needle: str,
    repo_root: Path,
    repo_files: Sequence[str],
    text_cache: Dict[str, str],
    kind: str,
) -> List[Match]:
    matches: List[Match] = []
    word_re = re.compile(rf"\b{re.escape(needle)}\b") if is_identifier(needle) else None
    for rel_path in repo_files:
        text = text_cache.setdefault(rel_path, read_text(repo_root / rel_path))
        if not text:
            continue
        for line_no, line in enumerate(text.splitlines(), start=1):
            if needle not in line:
                continue
            if word_re and not word_re.search(line):
                continue
            matches.append(Match(rel_path, line_no, line.strip(), kind))
    return matches


def resolve_js_spec(repo_root: Path, source_file: str, spec: str) -> List[str]:
    rel_path = Path(source_file)
    candidates: List[Path] = []
    base_dir = (repo_root / rel_path).parent

    if spec.startswith("."):
        target_base = (base_dir / spec).resolve()
        candidates.extend(resolve_file_variants(target_base))
    elif spec.startswith("@/"):
        src_dir = repo_root / "src"
        if src_dir.exists():
            candidates.extend(resolve_file_variants((src_dir / spec[2:]).resolve()))
    elif spec.startswith("~/"):
        candidates.extend(resolve_file_variants((repo_root / spec[2:]).resolve()))
    return [repo_rel(path, repo_root) for path in candidates if path.exists()]


def resolve_file_variants(base_path: Path) -> List[Path]:
    suffix = base_path.suffix
    candidates: List[Path] = []
    if suffix:
        candidates.append(base_path)
    else:
        for extension in JS_EXTENSIONS | PY_EXTENSIONS | GO_EXTENSIONS | SHELL_EXTENSIONS:
            candidates.append(base_path.with_suffix(extension))
        for name in COMMON_INDEX_NAMES:
            candidates.append(base_path / name)
    if base_path.is_dir():
        for name in COMMON_INDEX_NAMES:
            candidates.append(base_path / name)
    deduped: List[Path] = []
    seen: Set[str] = set()
    for candidate in candidates:
        key = str(candidate)
        if key in seen:
            continue
        deduped.append(candidate)
        seen.add(key)
    return deduped


def find_python_package_roots(repo_root: Path, source_files: Sequence[str]) -> Set[str]:
    roots: Set[str] = set()
    for rel_path in source_files:
        if Path(rel_path).suffix != ".py":
            continue
        parts = Path(rel_path).parts
        if parts:
            roots.add(parts[0])
    return roots


def resolve_python_spec(
    repo_root: Path,
    source_file: str,
    spec: str,
    package_roots: Set[str],
) -> List[str]:
    base = repo_root / source_file
    base_dir = base.parent
    candidates: List[Path] = []

    if spec.startswith("."):
        dots = len(spec) - len(spec.lstrip("."))
        module = spec.lstrip(".")
        anchor = base_dir
        for _ in range(max(dots - 1, 0)):
            anchor = anchor.parent
        if module:
            anchor = anchor / module.replace(".", "/")
        candidates.extend(resolve_python_module(anchor))
    else:
        root = spec.split(".", 1)[0]
        if root in package_roots:
            anchor = repo_root / spec.replace(".", "/")
            candidates.extend(resolve_python_module(anchor))
    return [repo_rel(path, repo_root) for path in candidates if path.exists()]


def resolve_python_module(anchor: Path) -> List[Path]:
    return [anchor.with_suffix(".py"), anchor / "__init__.py"]


def read_go_module_path(repo_root: Path) -> str:
    go_mod = repo_root / "go.mod"
    if not go_mod.exists():
        return ""
    for line in go_mod.read_text(encoding="utf-8", errors="ignore").splitlines():
        line = line.strip()
        if line.startswith("module "):
            return line.split(None, 1)[1].strip()
    return ""


def resolve_go_spec(repo_root: Path, module_path: str, spec: str) -> List[str]:
    if not module_path or not spec.startswith(module_path):
        return []
    relative = spec[len(module_path) :].lstrip("/")
    target_dir = repo_root / relative
    if not target_dir.exists():
        return []
    results = sorted(repo_rel(path, repo_root) for path in target_dir.glob("*.go"))
    return results


def resolve_shell_spec(repo_root: Path, source_file: str, spec: str) -> List[str]:
    base_dir = (repo_root / source_file).parent
    target = Path(spec)
    if not target.is_absolute():
        target = (base_dir / target).resolve()
    if target.exists():
        return [repo_rel(target, repo_root)]
    return []


def extract_import_targets(
    repo_root: Path,
    source_file: str,
    text: str,
    package_roots: Set[str],
    go_module_path: str,
) -> Tuple[Set[str], Set[str], int]:
    rel_path = Path(source_file)
    suffix = rel_path.suffix
    local_targets: Set[str] = set()
    external_specs: Set[str] = set()
    unresolved = 0

    specs: List[str] = []
    if suffix in JS_EXTENSIONS:
        for pattern in (
            re.compile(r"""from\s+['"]([^'"]+)['"]"""),
            re.compile(r"""import\s+['"]([^'"]+)['"]"""),
            re.compile(r"""require\(\s*['"]([^'"]+)['"]\s*\)"""),
            re.compile(r"""export\s+.+?\sfrom\s+['"]([^'"]+)['"]"""),
        ):
            specs.extend(match.group(1) for match in pattern.finditer(text))
        for spec in specs:
            resolved = resolve_js_spec(repo_root, source_file, spec)
            if resolved:
                local_targets.update(resolved)
            else:
                external_specs.add(spec)
                if spec.startswith((".", "@/","~/")):
                    unresolved += 1
    elif suffix in PY_EXTENSIONS:
        for pattern in (
            re.compile(r"^\s*from\s+([.\w]+)\s+import\b", re.MULTILINE),
            re.compile(r"^\s*import\s+([.\w]+)", re.MULTILINE),
        ):
            specs.extend(match.group(1) for match in pattern.finditer(text))
        for spec in specs:
            resolved = resolve_python_spec(repo_root, source_file, spec, package_roots)
            if resolved:
                local_targets.update(resolved)
            else:
                external_specs.add(spec)
                if spec.startswith("."):
                    unresolved += 1
    elif suffix in GO_EXTENSIONS:
        specs.extend(match.group(1) for match in re.finditer(r'"([^"]+)"', text))
        for spec in specs:
            resolved = resolve_go_spec(repo_root, go_module_path, spec)
            if resolved:
                local_targets.update(resolved)
            else:
                external_specs.add(spec)
    elif suffix in SHELL_EXTENSIONS:
        for pattern in (
            re.compile(r"^\s*(?:source|\.)\s+([^\s]+)", re.MULTILINE),
        ):
            specs.extend(match.group(1).strip("\"'") for match in pattern.finditer(text))
        for spec in specs:
            resolved = resolve_shell_spec(repo_root, source_file, spec)
            if resolved:
                local_targets.update(resolved)
            else:
                external_specs.add(spec)

    return local_targets, external_specs, unresolved


def build_import_graph(
    repo_root: Path,
    source_files: Sequence[str],
    text_cache: Dict[str, str],
) -> Tuple[Dict[str, Set[str]], Dict[str, Set[str]], Dict[str, Set[str]], int]:
    graph: Dict[str, Set[str]] = defaultdict(set)
    external_specs: Dict[str, Set[str]] = defaultdict(set)
    reverse_graph: Dict[str, Set[str]] = defaultdict(set)
    unresolved_count = 0
    package_roots = find_python_package_roots(repo_root, source_files)
    go_module_path = read_go_module_path(repo_root)

    for rel_path in source_files:
        text = text_cache.setdefault(rel_path, read_text(repo_root / rel_path))
        if not text:
            continue
        local_targets, externals, unresolved = extract_import_targets(
            repo_root,
            rel_path,
            text,
            package_roots,
            go_module_path,
        )
        if local_targets:
            graph[rel_path].update(local_targets)
            for target in local_targets:
                reverse_graph[target].add(rel_path)
        if externals:
            external_specs[rel_path].update(externals)
        unresolved_count += unresolved

    return graph, reverse_graph, external_specs, unresolved_count


def expand_reverse_chain(
    seeds: Iterable[str],
    reverse_graph: Dict[str, Set[str]],
    depth: int,
) -> Dict[int, List[str]]:
    results: Dict[int, List[str]] = defaultdict(list)
    frontier = list(seeds)
    seen: Set[str] = set(frontier)
    for level in range(1, max(depth, 0) + 1):
        next_frontier: List[str] = []
        for node in frontier:
            for importer in sorted(reverse_graph.get(node, set())):
                if importer in seen:
                    continue
                results[level].append(importer)
                next_frontier.append(importer)
                seen.add(importer)
        frontier = next_frontier
        if not frontier:
            break
    return results


def find_path_mentions(
    target_files: Sequence[str],
    repo_root: Path,
    repo_files: Sequence[str],
    text_cache: Dict[str, str],
) -> List[Match]:
    matches: List[Match] = []
    needles: Set[str] = set()
    for rel_path in target_files:
        path = Path(rel_path)
        without_suffix = str(path.with_suffix("")).replace("\\", "/")
        needles.update(
            {
                path.name,
                without_suffix,
                without_suffix.split("/")[-1],
            }
        )
    for rel_path in repo_files:
        text = text_cache.setdefault(rel_path, read_text(repo_root / rel_path))
        if not text:
            continue
        for line_no, line in enumerate(text.splitlines(), start=1):
            if any(needle and needle in line for needle in needles):
                matches.append(Match(rel_path, line_no, line.strip(), "path_mention"))
    return matches


def dedupe_matches(matches: Iterable[Match]) -> List[Match]:
    seen: Set[Tuple[str, int, str, str, int]] = set()
    results: List[Match] = []
    for match in matches:
        key = (match.file, match.line, match.text, match.kind, match.depth)
        if key in seen:
            continue
        seen.add(key)
        results.append(match)
    return sorted(results, key=lambda item: (item.file, item.line, item.kind, item.depth))


def find_neighbor_tests(
    target_files: Sequence[str],
    target_symbols: Sequence[str],
    repo_root: Path,
    repo_files: Sequence[str],
    text_cache: Dict[str, str],
) -> List[Match]:
    matches: List[Match] = []
    stems = {Path(path).stem for path in target_files}
    for rel_path in repo_files:
        if not is_test_file(rel_path):
            continue
        text = text_cache.setdefault(rel_path, read_text(repo_root / rel_path))
        if not text:
            continue
        matched = False
        if any(stem and stem in Path(rel_path).stem for stem in stems):
            matches.append(Match(rel_path, 1, "basename-neighbor", "neighbor_test"))
            matched = True
        if matched:
            continue
        for line_no, line in enumerate(text.splitlines(), start=1):
            if any(symbol in line for symbol in target_symbols) or any(
                Path(target).name in line for target in target_files
            ):
                matches.append(Match(rel_path, line_no, line.strip(), "test_reference"))
                break
    return dedupe_matches(matches)


def find_keyword_signals(
    target_files: Sequence[str],
    repo_root: Path,
    text_cache: Dict[str, str],
    patterns: Sequence[re.Pattern[str]],
    kind: str,
) -> List[Match]:
    matches: List[Match] = []
    for rel_path in target_files:
        text = text_cache.setdefault(rel_path, read_text(repo_root / rel_path))
        if not text:
            continue
        for line_no, line in enumerate(text.splitlines(), start=1):
            if any(pattern.search(line) for pattern in patterns):
                matches.append(Match(rel_path, line_no, line.strip(), kind))
    return dedupe_matches(matches)


def discover_symmetry_candidates(
    target_symbols: Sequence[str],
    target_files: Sequence[str],
    repo_root: Path,
    repo_files: Sequence[str],
    text_cache: Dict[str, str],
) -> Dict[str, List[Match]]:
    candidates: Dict[str, List[Match]] = {}
    raw_values = list(target_symbols)
    raw_values.extend(Path(path).stem for path in target_files)

    for value in raw_values:
        lower = value.lower()
        for left, right in SYMMETRY_PAIRS:
            if left in lower:
                candidate = re.sub(left, right, value, flags=re.IGNORECASE)
            elif right in lower:
                candidate = re.sub(right, left, value, flags=re.IGNORECASE)
            else:
                continue
            hits = search_string_matches(candidate, repo_root, repo_files, text_cache, "symmetry")
            filtered = [
                hit
                for hit in hits
                if not any(same_path(hit.file, path) for path in target_files)
            ]
            if filtered:
                candidates[candidate] = dedupe_matches(filtered)
    return candidates


def module_bucket(path: str) -> str:
    parts = Path(path).parts
    if not parts:
        return "."
    if parts[0] in {"src", "app", "lib", "pkg"} and len(parts) >= 2:
        return "/".join(parts[:2])
    return parts[0]


def risk_assessment(
    target_files: Sequence[str],
    target_symbols: Sequence[str],
    direct_refs: Sequence[Match],
    reverse_chain: Dict[int, List[str]],
    outbound_local: Sequence[str],
    neighbor_tests: Sequence[Match],
    config_signals: Sequence[Match],
    dynamic_signals: Sequence[Match],
    symmetry_candidates: Dict[str, List[Match]],
    unresolved_imports: int,
    ambiguous_symbols: Sequence[str],
) -> Tuple[str, int, List[str], str]:
    score = 0
    reasons: List[str] = []

    direct_file_count = len({match.file for match in direct_refs})
    reverse_count = sum(len(files) for files in reverse_chain.values())
    outbound_count = len(set(outbound_local))
    impacted_buckets = {module_bucket(match.file) for match in direct_refs}
    impacted_buckets.update(module_bucket(path) for files in reverse_chain.values() for path in files)

    if direct_file_count >= 8:
        score += 4
        reasons.append(f"+4 many directly affected caller / consumer files ({direct_file_count})")
    elif direct_file_count >= 4:
        score += 2
        reasons.append(f"+2 several direct references already exist ({direct_file_count})")

    if reverse_count >= 8:
        score += 3
        reasons.append(f"+3 reverse import chain is broad / deep ({reverse_count} upstream files)")
    elif reverse_count >= 3:
        score += 1
        reasons.append(f"+1 second-layer or deeper impact found ({reverse_count} upstream files)")

    if outbound_count >= 6:
        score += 2
        reasons.append(f"+2 target files already depend on many local modules ({outbound_count})")

    if not neighbor_tests:
        score += 1
        reasons.append("+1 few nearby tests or direct test references found")

    if config_signals:
        score += 2
        reasons.append("+2 config / environment access may amplify impact")

    if dynamic_signals:
        score += 2
        reasons.append("+2 dynamic dispatch / registration signals reduce static confidence")

    if symmetry_candidates:
        score += 1
        reasons.append("+1 symmetry / loopback candidates may require paired updates")

    if unresolved_imports:
        score += 1
        reasons.append(f"+1 unresolved imports ({unresolved_imports}) make the static graph incomplete")

    if ambiguous_symbols:
        score += 2
        reasons.append(f"+2 target symbols have ambiguous definitions: {', '.join(ambiguous_symbols)}")

    if len(impacted_buckets) >= 3:
        score += 1
        reasons.append(f"+1 impact spans multiple module buckets: {', '.join(sorted(impacted_buckets))}")

    public_surface = any(
        any(token in path for token in ("/api/", "/shared/", "/common/", "/core/", "/types/", "/hooks/"))
        or Path(path).name.startswith("index.")
        for path in target_files
    ) or any(symbol[0].isupper() for symbol in target_symbols if symbol)
    if public_surface:
        score += 1
        reasons.append("+1 target looks like a public surface or shared module")

    if score >= 8:
        level = "🔴 High"
        gate = "stop direct editing and shrink scope or rewrite the plan first"
    elif score >= 4:
        level = "🟡 Medium"
        gate = "continue only if direct callers and key consumers are included in verification"
    else:
        level = "🟢 Low"
        gate = "impact appears relatively controlled; continue with the smallest cut"

    if not reasons:
        reasons.append("+0 static signals suggest a concentrated impact area")

    return level, score, reasons, gate


def select_top_matches(matches: Sequence[Match], max_refs: int) -> List[Match]:
    return list(matches[:max_refs])


def build_test_recommendations(
    target_files: Sequence[str],
    direct_refs: Sequence[Match],
    reverse_chain: Dict[int, List[str]],
    neighbor_tests: Sequence[Match],
    symmetry_candidates: Dict[str, List[Match]],
    config_signals: Sequence[Match],
) -> List[Tuple[str, str, str]]:
    recommendations: List[Tuple[str, str, str]] = []
    for path in target_files:
        recommendations.append(("🔴 Must verify", path, "core target of this change"))

    seen_files = {path for _, path, _ in recommendations}
    for match in direct_refs:
        if match.file in seen_files or is_test_file(match.file):
            continue
        recommendations.append(("🔴 Must verify", match.file, "direct callers / consumers"))
        seen_files.add(match.file)

    for depth, files in reverse_chain.items():
        priority = "🟡 Recommended" if depth == 1 else "⚪ Optional"
        reason = "direct import chain" if depth == 1 else f"{depth} layer-up reverse import chain"
        for path in files:
            if path in seen_files:
                continue
            recommendations.append((priority, path, reason))
            seen_files.add(path)

    for match in neighbor_tests:
        if match.file in seen_files:
            continue
        recommendations.append(("🟡 Recommended", match.file, "neighbor test / regression entrypoint"))
        seen_files.add(match.file)

    if config_signals:
        for match in config_signals:
            if match.file in seen_files:
                continue
            recommendations.append(("🟡 Recommended", match.file, "config / environment access detected"))
            seen_files.add(match.file)

    for candidate, hits in symmetry_candidates.items():
        for hit in hits:
            if hit.file in seen_files:
                continue
            recommendations.append(("🟡 Recommended", hit.file, f"symmetry candidate: {candidate}"))
            seen_files.add(hit.file)
            break

    return recommendations


def truncate_text(value: str, limit: int = 140) -> str:
    return value if len(value) <= limit else value[: limit - 1] + "…"


def markdown_table(rows: Sequence[Sequence[str]], headers: Sequence[str]) -> List[str]:
    if not rows:
        return []
    lines = ["| " + " | ".join(headers) + " |", "| " + " | ".join(["---"] * len(headers)) + " |"]
    for row in rows:
        safe = [cell.replace("\n", " ").replace("|", "\\|") for cell in row]
        lines.append("| " + " | ".join(safe) + " |")
    return lines


def render_markdown(report: dict) -> str:
    lines: List[str] = []
    lines.append("# Blast Radius Report")
    lines.append("")
    lines.append(f"- Generated: `{report['generated_at']}`")
    lines.append(f"- Repository: `{report['repo_root']}`")
    lines.append(f"- Mode: `{report['mode']}`")
    if report["task"]:
        lines.append(f"- Task: `{report['task']}`")
    if report["step"]:
        lines.append(f"- Step: `{report['step']}`")
    lines.append(f"- Risk level: **{report['risk_level']}**（score={report['risk_score']}）")
    lines.append(f"- Gate: **{report['gate']}**")
    lines.append("")
    lines.append("## Targets")
    if report["target_files"]:
        for path in report["target_files"]:
            lines.append(f"- File: `{path}`")
    if report["target_symbols"]:
        for symbol in report["target_symbols"]:
            lines.append(f"- Symbol: `{symbol}`")
    lines.append(f"- Reverse depth: `{report['depth']}`")
    lines.append("")
    if report["definitions"]:
        lines.append("## Definitions")
        lines.extend(
            markdown_table(
                [
                    [item["symbol"], item["file"], str(item["line"]), truncate_text(item["text"])]
                    for item in report["definitions"]
                ],
                ["Symbol", "File", "Line", "Matched text"],
            )
        )
        lines.append("")

    lines.append("## Direct impact (callers / references)")
    if report["direct_references"]:
        lines.extend(
            markdown_table(
                [
                    [item["file"], str(item["line"]), item["kind"], truncate_text(item["text"])]
                    for item in report["direct_references"]
                ],
                ["File", "Line", "Type", "Matched text"],
            )
        )
    else:
        lines.append("- No obvious direct callers were found, or static search found nothing.")
    lines.append("")

    lines.append("## Reverse import chain")
    if report["reverse_chain"]:
        for depth, files in report["reverse_chain"].items():
            lines.append(f"### Depth {depth}")
            for path in files:
                lines.append(f"- `{path}`")
    else:
        lines.append("- No additional reverse import chain was found.")
    lines.append("")

    lines.append("## Outbound / local dependencies")
    local_deps = report["outbound_local_dependencies"]
    external_deps = report["outbound_external_dependencies"]
    if local_deps:
        for path in local_deps:
            lines.append(f"- Local dependency: `{path}`")
    if external_deps:
        for spec in external_deps:
            lines.append(f"- External dependency: `{spec}`")
    if not local_deps and not external_deps:
        lines.append("- No parseable dependency was found, or this file type is not supported.")
    lines.append("")

    lines.append("## Test assets / nearby tests")
    if report["neighbor_tests"]:
        lines.extend(
            markdown_table(
                [
                    [item["file"], str(item["line"]), item["kind"], truncate_text(item["text"])]
                    for item in report["neighbor_tests"]
                ],
                ["File", "Line", "Type", "Matched text"],
            )
        )
    else:
        lines.append("- No nearby tests were found; add regression coverage manually.")
    lines.append("")

    lines.append("## Config / dynamic signals")
    if report["config_signals"]:
        lines.append("### Config / environment")
        lines.extend(
            markdown_table(
                [
                    [item["file"], str(item["line"]), truncate_text(item["text"])]
                    for item in report["config_signals"]
                ],
                ["File", "Line", "Matched text"],
            )
        )
    if report["dynamic_signals"]:
        lines.append("### Dynamic dispatch / registration")
        lines.extend(
            markdown_table(
                [
                    [item["file"], str(item["line"]), truncate_text(item["text"])]
                    for item in report["dynamic_signals"]
                ],
                ["File", "Line", "Matched text"],
            )
        )
    if not report["config_signals"] and not report["dynamic_signals"]:
        lines.append("- No strong config or dynamic-dispatch signal was found.")
    lines.append("")

    lines.append("## Symmetry candidates")
    if report["symmetry_candidates"]:
        for candidate, hits in report["symmetry_candidates"].items():
            lines.append(f"### `{candidate}`")
            for item in hits:
                lines.append(f"- `{item['file']}:{item['line']}` {truncate_text(item['text'])}")
    else:
        lines.append("- No obvious symmetry or loopback candidates were found.")
    lines.append("")

    lines.append("## Risk score")
    for reason in report["risk_reasons"]:
        lines.append(f"- {reason}")
    lines.append("")

    lines.append("## Suggested verification scope")
    if report["test_recommendations"]:
        lines.extend(
            markdown_table(
                [[priority, path, reason] for priority, path, reason in report["test_recommendations"]],
                ["Priority", "Module", "Reason"],
            )
        )
    else:
        lines.append("- No automatic recommendation available; at least verify the changed path and original reproduction path.")
    lines.append("")

    lines.append("## Blind spots / manual follow-up needed")
    if report["blind_spots"]:
        for item in report["blind_spots"]:
            lines.append(f"- {item}")
    else:
        lines.append("- No extra blind spots were detected, but data flow and business-rule review is still required.")
    lines.append("")

    lines.append("## Recommended action")
    lines.append(f"- Recommendation: **{report['gate']}**")
    lines.append("- Review data flow and business consumers before editing code.")
    lines.append("- Rerun the script if the real changed files or symbols exceed this report's targets.")
    return "\n".join(lines).strip() + "\n"


def auto_output_paths(
    repo_root: Path,
    task: str,
    target_files: Sequence[str],
    target_symbols: Sequence[str],
) -> Tuple[Path, Path]:
    stamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    parts: List[str] = []
    if task:
        parts.append(task)
    for symbol in target_symbols[:2]:
        parts.append(symbol)
    if not parts:
        for path in target_files[:2]:
            parts.append(Path(path).stem)
    if not parts:
        parts.append("blast-radius")
    slug = "-".join(slugify(part) for part in parts if part)
    base_dir = repo_root / ".autodev" / "blast-radius"
    return base_dir / f"{stamp}-{slug}.md", base_dir / f"{stamp}-{slug}.json"


def slugify(value: str) -> str:
    slug = re.sub(r"[^A-Za-z0-9]+", "-", value).strip("-").lower()
    return slug or "blast-radius"


def write_file(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")


def summarize_stdout(report: dict) -> str:
    direct_files = len({item["file"] for item in report["direct_references"]})
    reverse_count = sum(len(files) for files in report["reverse_chain"].values())
    return (
        f"Blast Radius {report['risk_level']} | gate={report['gate']} | "
        f"direct={direct_files} | transitive={reverse_count} | "
        f"tests={len(report['neighbor_tests'])}"
    )


def build_target_slug(target_files: Sequence[str], target_symbols: Sequence[str]) -> str:
    parts: List[str] = []
    for symbol in target_symbols[:2]:
        parts.append(slugify(symbol))
    if not parts:
        for path in target_files[:2]:
            parts.append(slugify(Path(path).stem))
    return "-".join(part for part in parts if part) or "target"


def build_start_label(
    mode: str,
    task: str,
    step: str,
    depth: int,
    target_files: Sequence[str],
    target_symbols: Sequence[str],
    threshold_label: str,
) -> str:
    task_slug = slugify(task) if task else slugify(mode)
    scope_slug = f"step{step}" if step else slugify(mode)
    target_slug = build_target_slug(target_files, target_symbols)
    marker_id = f"BR-{task_slug}-{scope_slug}-{target_slug}-d{depth}"
    focus_parts: List[str] = []
    if target_symbols:
        symbol_part = ",".join(target_symbols[:3])
        if len(target_symbols) > 3:
            symbol_part += f"+{len(target_symbols) - 3}"
        focus_parts.append(f"symbol={symbol_part}")
    if target_files:
        file_part = ",".join(target_files[:2])
        if len(target_files) > 2:
            file_part += f"+{len(target_files) - 2}"
        focus_parts.append(f"file={file_part}")
    focus_parts.append(f"mode={mode}")
    if step:
        focus_parts.append(f"step={step}")
    if task:
        focus_parts.append(f"task={task}")
    if threshold_label:
        focus_parts.append(f"threshold={threshold_label}")
    focus_parts.append(f"depth={depth}")
    return f"💥 Blast-radius start - [{marker_id}] " + "{" + " | ".join(focus_parts) + "}"


def risk_rank(level: str) -> int:
    if "🔴" in level:
        return 3
    if "🟡" in level:
        return 2
    return 1


def build_summary(report: dict) -> dict:
    return {
        "mode": report["mode"],
        "task": report["task"],
        "step": report["step"],
        "risk_level": report["risk_level"],
        "risk_rank": risk_rank(report["risk_level"]),
        "risk_score": report["risk_score"],
        "gate": report["gate"],
        "target_files": report["target_files"],
        "target_symbols": report["target_symbols"],
        "report_path": report.get("report_path", ""),
        "json_path": report.get("json_path", ""),
        "direct_reference_count": len({item["file"] for item in report["direct_references"]}),
        "transitive_reference_count": sum(len(files) for files in report["reverse_chain"].values()),
        "neighbor_test_count": len(report["neighbor_tests"]),
        "blind_spot_count": len(report["blind_spots"]),
    }


def main() -> int:
    args = parse_args()
    repo_root = get_repo_root(args.repo_root)
    os.chdir(repo_root)
    config = load_config(repo_root)

    depth = args.depth
    if depth is None:
        depth = int(config_get(config, "blast_radius.default_reverse_depth", 2))
    max_refs = args.max_refs
    if max_refs is None:
        max_refs = int(config_get(config, "blast_radius.max_refs_per_section", 25))

    target_files = list(args.file)
    target_symbols = list(args.symbol)
    for raw_target in args.target:
        if "::" in raw_target:
            file_part, symbol_part = raw_target.split("::", 1)
            if file_part:
                target_files.append(file_part)
            if symbol_part:
                target_symbols.append(symbol_part)
        else:
            target_files.append(raw_target)

    target_files = [normalize_repo_path(path, repo_root) for path in target_files]
    target_files = sorted(dict.fromkeys(target_files))
    target_symbols = sorted(dict.fromkeys(symbol for symbol in target_symbols if symbol))

    if not target_files and not target_symbols:
        print("blast-radius.py: at least one --file, --symbol, or --target is required", file=sys.stderr)
        return 2

    if not args.quiet:
        print(
            build_start_label(
                args.mode,
                args.task,
                args.step,
                depth,
                target_files,
                target_symbols,
                args.threshold_label,
            )
        )
        print("")

    repo_files = list_repo_files(repo_root)
    source_files = list_source_files(repo_root, repo_files)
    text_cache: Dict[str, str] = {}
    graph, reverse_graph, external_specs, unresolved_imports = build_import_graph(
        repo_root, source_files, text_cache
    )

    definitions: List[dict] = []
    definition_matches_by_symbol: Dict[str, List[Match]] = {}
    ambiguous_symbols: List[str] = []
    derived_target_files: Set[str] = set(target_files)
    for symbol in target_symbols:
        matches = find_symbol_definitions(symbol, repo_root, source_files, text_cache)
        definition_matches_by_symbol[symbol] = matches
        if len({match.file for match in matches}) > 1:
            ambiguous_symbols.append(symbol)
        for match in matches:
            derived_target_files.add(match.file)
            definitions.append(
                {
                    "symbol": symbol,
                    "file": match.file,
                    "line": match.line,
                    "text": match.text,
                }
            )

    target_files = sorted(derived_target_files)
    direct_refs: List[Match] = []
    if target_symbols:
        for symbol in target_symbols:
            matches = search_string_matches(symbol, repo_root, repo_files, text_cache, "symbol_ref")
            definition_lines = {
                (match.file, match.line)
                for match in definition_matches_by_symbol.get(symbol, [])
            }
            direct_refs.extend(
                match
                for match in matches
                if (match.file, match.line) not in definition_lines
                and not any(same_path(match.file, path) for path in target_files)
            )

    if target_files:
        direct_importers = [
            Match(path, 1, "reverse-import", "direct_importer")
            for path in sorted({imp for target in target_files for imp in reverse_graph.get(target, set())})
        ]
        direct_refs.extend(direct_importers)
        path_mentions = find_path_mentions(target_files, repo_root, repo_files, text_cache)
        direct_refs.extend(
            match
            for match in path_mentions
            if not any(same_path(match.file, path) for path in target_files)
        )

    direct_refs = dedupe_matches(direct_refs)
    reverse_chain = expand_reverse_chain(target_files, reverse_graph, depth)

    outbound_local = sorted(
        {
            dependency
            for target in target_files
            for dependency in graph.get(target, set())
            if not same_path(target, dependency)
        }
    )
    outbound_external = sorted(
        {
            dependency
            for target in target_files
            for dependency in external_specs.get(target, set())
        }
    )

    neighbor_tests = find_neighbor_tests(
        target_files, target_symbols, repo_root, repo_files, text_cache
    )
    config_signals = find_keyword_signals(target_files, repo_root, text_cache, CONFIG_PATTERNS, "config_signal")
    dynamic_signals = find_keyword_signals(target_files, repo_root, text_cache, DYNAMIC_PATTERNS, "dynamic_signal")
    symmetry_candidates = {
        candidate: [
            asdict(match)
            for match in select_top_matches(matches, max_refs)
        ]
        for candidate, matches in discover_symmetry_candidates(
            target_symbols, target_files, repo_root, repo_files, text_cache
        ).items()
    }

    risk_level, risk_score, risk_reasons, gate = risk_assessment(
        target_files,
        target_symbols,
        direct_refs,
        reverse_chain,
        outbound_local,
        neighbor_tests,
        config_signals,
        dynamic_signals,
        symmetry_candidates,
        unresolved_imports,
        ambiguous_symbols,
    )

    blind_spots: List[str] = []
    if not target_files:
        blind_spots.append("No concrete target file was identified; add `--file` or confirm the symbol definition.")
    if ambiguous_symbols:
        blind_spots.append(f"The symbol has multiple definitions: {', '.join(ambiguous_symbols)}; narrow the targets before editing.")
    if unresolved_imports:
        blind_spots.append(f"There are {unresolved_imports} unresolved imports; the reverse import chain may be incomplete.")
    if dynamic_signals:
        blind_spots.append("Dynamic dispatch or registration was detected; add manual runtime and data-flow review.")
    if not neighbor_tests:
        blind_spots.append("No nearby tests were found; add at least one protective regression path manually.")

    report = {
        "generated_at": datetime.now().isoformat(timespec="seconds"),
        "repo_root": str(repo_root),
        "mode": args.mode,
        "task": args.task,
        "step": args.step,
        "depth": depth,
        "target_files": target_files,
        "target_symbols": target_symbols,
        "definitions": definitions,
        "direct_references": [asdict(match) for match in select_top_matches(direct_refs, max_refs)],
        "reverse_chain": {
            str(level): files[:max_refs]
            for level, files in reverse_chain.items()
            if files
        },
        "outbound_local_dependencies": outbound_local[:max_refs],
        "outbound_external_dependencies": outbound_external[:max_refs],
        "neighbor_tests": [asdict(match) for match in select_top_matches(neighbor_tests, max_refs)],
        "config_signals": [asdict(match) for match in select_top_matches(config_signals, max_refs)],
        "dynamic_signals": [asdict(match) for match in select_top_matches(dynamic_signals, max_refs)],
        "symmetry_candidates": symmetry_candidates,
        "risk_level": risk_level,
        "risk_score": risk_score,
        "risk_reasons": risk_reasons,
        "gate": gate,
        "blind_spots": blind_spots,
    }
    report["test_recommendations"] = build_test_recommendations(
        target_files,
        direct_refs,
        reverse_chain,
        neighbor_tests,
        {
            candidate: [Match(**match) for match in matches]
            for candidate, matches in symmetry_candidates.items()
        },
        config_signals,
    )[:max_refs]

    markdown = render_markdown(report)

    report_path: Optional[Path] = None
    json_path: Optional[Path] = None
    if args.write or args.report:
        report_path, auto_json_path = auto_output_paths(
            repo_root, args.task, target_files, target_symbols
        )
        if args.report:
            report_path = (repo_root / args.report).resolve() if not Path(args.report).is_absolute() else Path(args.report)
        if args.json:
            json_path = (repo_root / args.json).resolve() if not Path(args.json).is_absolute() else Path(args.json)
        else:
            json_path = auto_json_path
        write_file(report_path, markdown)
        write_file(json_path, json.dumps(report, ensure_ascii=False, indent=2) + "\n")

        should_update_current = bool(config_get(config, "blast_radius.update_current_report", True))
        if args.no_current:
            should_update_current = False
        if should_update_current:
            current_path = repo_root / ".autodev" / "current-blast-radius.md"
            current_content = markdown
            if report_path:
                current_content = (
                    f"# Current Blast Radius\n\n"
                    f"- Latest report: `{repo_rel(report_path, repo_root)}`\n"
                    f"- Risk level: **{risk_level}**\n"
                    f"- Gate: **{gate}**\n\n"
                    "━━━━━━━━━━━━━━━━━━━━\n\n"
                    + markdown
                )
            write_file(current_path, current_content)
        report["report_path"] = repo_rel(report_path, repo_root)
        report["json_path"] = repo_rel(json_path, repo_root)

    if args.summary_json:
        summary_path = (
            (repo_root / args.summary_json).resolve()
            if not Path(args.summary_json).is_absolute()
            else Path(args.summary_json)
        )
        write_file(summary_path, json.dumps(build_summary(report), ensure_ascii=False, indent=2) + "\n")

    if args.quiet:
        print(summarize_stdout(report))
    else:
        print(markdown.rstrip())
        if report.get("report_path"):
            print("")
            print(f"Report written to: {report['report_path']}")
            print(f"JSON written to: {report['json_path']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
