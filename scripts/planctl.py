#!/usr/bin/env python3
"""
Usage:
  python3 scripts/planctl.py detect-drift [--mode precheck|full] [--repo-root PATH]

Detect lightweight or full plan drift signals for the active auto-dev-team control plane.
"""

from __future__ import annotations

import argparse
import json
import pathlib
import re
import sys
from datetime import datetime


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Detect plan drift signals for auto-dev-team.")
    subparsers = parser.add_subparsers(dest="command", required=True)

    detect = subparsers.add_parser("detect-drift", help="Detect plan drift signals.")
    detect.add_argument("--mode", choices=("precheck", "full"), default="precheck")
    detect.add_argument("--repo-root", default=".")
    return parser.parse_args()


def load_json(path: pathlib.Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def parse_markdown_step_refs(path: pathlib.Path) -> set[str]:
    if not path.exists():
        return set()
    text = path.read_text(encoding="utf-8", errors="ignore")
    return set(re.findall(r"\[step_ref:\s*(STEP-[^\]]+)\]", text))


def parse_timestamp(text: str | None) -> datetime | None:
    if not text:
        return None
    if text.startswith("YYYY-"):
        return None
    return datetime.strptime(text, "%Y-%m-%dT%H:%M:%S%z")


def detect(repo_root: pathlib.Path, mode: str) -> dict:
    autodev = repo_root / ".autodev"
    flow_path = autodev / "current-flow.json"
    stack_path = autodev / "current-stack.json"
    steps_path = autodev / "current-steps.md"
    roadmap_path = autodev / "project-roadmap.md"

    signals: list[dict] = []

    if not flow_path.exists():
        return {
            "mode": mode,
            "drift_detected": False,
            "signals": [],
            "reason": "no_active_flow",
        }

    flow = load_json(flow_path)
    stack = load_json(stack_path) if stack_path.exists() else {}
    step_refs = parse_markdown_step_refs(steps_path)
    now = datetime.now().astimezone()

    flow_id = flow.get("flow_id")
    active_mode = flow.get("active_mode")
    active_mode_key = str(active_mode or "").strip().lower()
    active_step = flow.get("active_step")
    required_artifacts = set(flow.get("required_artifacts") or [])
    declared_steps_path = (flow.get("artifacts") or {}).get("steps")

    if stack_path.exists():
        stack_flow = stack.get("flow_ref")
        if stack_flow and flow_id and stack_flow != flow_id:
            signals.append(
                {
                    "type": "stack_flow_mismatch",
                    "severity": "high",
                    "suspected_level": "flow",
                    "evidence": f"stack.flow_ref={stack_flow}, current-flow.flow_id={flow_id}",
                }
            )

    if active_step and active_step not in step_refs:
        signals.append(
            {
                "type": "missing_active_step",
                "severity": "medium",
                "suspected_level": "flow",
                "evidence": f"active_step={active_step} not found in current-steps.md",
            }
        )

    if stack_path.exists():
        last_touch = parse_timestamp(stack.get("last_meaningful_touch_at"))
        threshold = int(stack.get("resume_threshold_hours", 24))
        if last_touch is not None:
            hours = (now - last_touch).total_seconds() / 3600
            if hours >= threshold:
                signals.append(
                    {
                        "type": "staleness",
                        "severity": "medium" if mode == "precheck" else "high",
                        "suspected_level": "flow",
                        "evidence": f"hours_since_touch={hours:.1f}, threshold={threshold}",
                    }
                )

    steps_required = bool(
        active_step
        or flow.get("plan_ref")
        or declared_steps_path
        or "steps" in required_artifacts
        or active_mode_key == "step"
    )

    if steps_required and not steps_path.exists():
        signals.append(
            {
                "type": "missing_steps_plan",
                "severity": "medium",
                "suspected_level": "flow",
                "evidence": (
                    "flow has entered step-planning/execution semantics "
                    "but current-steps.md is missing"
                ),
            }
        )

    if mode == "full":
        if stack.get("project_ref") and not roadmap_path.exists():
            signals.append(
                {
                    "type": "missing_project_roadmap",
                    "severity": "medium",
                    "suspected_level": "project",
                    "evidence": f"project_ref={stack.get('project_ref')} but .autodev/project-roadmap.md is missing",
                }
            )

        if steps_path.exists():
            text = steps_path.read_text(encoding="utf-8", errors="ignore")
            planned_steps = len(step_refs)
            completed_steps = len(re.findall(r"^### Step \d+", text, flags=re.M))
            if planned_steps and completed_steps > planned_steps + 2:
                signals.append(
                    {
                        "type": "step_count_drift",
                        "severity": "medium",
                        "suspected_level": "phase",
                        "evidence": f"planned_step_refs={planned_steps}, execution_sections={completed_steps}",
                    }
                )

            if "superseded" in text.lower():
                signals.append(
                    {
                        "type": "superseded_plan_marker",
                        "severity": "high",
                        "suspected_level": "milestone",
                        "evidence": "current-steps.md contains superseded marker",
                    }
                )

    return {
        "mode": mode,
        "drift_detected": bool(signals),
        "signals": signals,
        "flow_ref": flow_id,
        "active_mode": active_mode,
        "step_ref": active_step,
    }


def main() -> int:
    args = parse_args()
    repo_root = pathlib.Path(args.repo_root).resolve()
    result = detect(repo_root, args.mode)
    print(json.dumps(result, ensure_ascii=False, indent=2))
    return 2 if result["drift_detected"] else 0


if __name__ == "__main__":
    raise SystemExit(main())
