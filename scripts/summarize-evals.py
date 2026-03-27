#!/usr/bin/env python3
"""summarize-evals.py — summarize eval result files under evals/results/."""

from __future__ import annotations

from collections import Counter, defaultdict
from pathlib import Path
import sys


REPO_DIR = Path(__file__).resolve().parent.parent
RESULTS_DIR = REPO_DIR / "evals" / "results"


def parse_result(path: Path) -> dict[str, str]:
    data: dict[str, str] = {}
    for line in path.read_text(encoding="utf-8").splitlines():
        if ":" not in line or line.startswith("#"):
            continue
        key, value = line.split(":", 1)
        data[key.strip()] = value.strip()
    return data


def avg(values: list[float]) -> str:
    if not values:
        return "-"
    return f"{sum(values) / len(values):.2f}"


def main() -> int:
    files = sorted(RESULTS_DIR.glob("*.md"))
    if not files:
        print("No eval results found.")
        return 0

    by_agent: dict[str, list[dict[str, str]]] = defaultdict(list)
    for path in files:
        parsed = parse_result(path)
        agent = parsed.get("agent", "unknown")
        by_agent[agent].append(parsed)

    print(f"Eval results found: {len(files)}")
    print("")
    print("| Agent | Runs | Pass | Partial | Fail | Avg Rework | Verify Yes | Policy Yes |")
    print("|---|---:|---:|---:|---:|---:|---:|---:|")

    for agent in sorted(by_agent):
        runs = by_agent[agent]
        pass_counts = Counter(run.get("pass", "").lower() for run in runs)
        verify_yes = sum(1 for run in runs if run.get("verification_quality", "").lower() == "yes")
        policy_yes = sum(1 for run in runs if run.get("policy_compliance", "").lower() == "yes")
        rework_values = []
        for run in runs:
            value = run.get("rework_count", "").strip()
            if value.isdigit():
                rework_values.append(float(value))
        print(
            f"| {agent} | {len(runs)} | {pass_counts.get('yes', 0)} | "
            f"{pass_counts.get('partial', 0)} | {pass_counts.get('no', 0)} | "
            f"{avg(rework_values)} | {verify_yes} | {policy_yes} |"
        )

    return 0


if __name__ == "__main__":
    sys.exit(main())
