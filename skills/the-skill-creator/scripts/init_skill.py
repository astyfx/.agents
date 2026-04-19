#!/usr/bin/env python3
"""Scaffold a new skill under the ~/.agents harness convention.

Creates:
    <root>/<skill-name>/SKILL.md        (frontmatter + stub sections)
    <root>/<skill-name>/scripts/        (optional, --resources scripts)
    <root>/<skill-name>/references/     (optional, --resources references)
    <root>/<skill-name>/assets/         (optional, --resources assets)

Defaults:
    root:             ~/.agents/skills
    compatible-tools: [claude, codex]
    category:         workflow
    name convention:  the-<slug>

Usage:
    init_skill.py <skill-name> [--root <dir>] [--description "..."]
                  [--resources scripts,references,assets]
                  [--compatible-tools claude,codex]
                  [--category <slug>]
                  [--test-prompts "p1" "p2" ...]
                  [--no-the-prefix]   allow names without "the-"

After creation, run:
    python3 ~/.agents/skills/the-skill-creator/scripts/quick_validate.py <skill_dir>
    bash   ~/.agents/scripts/sync-skills.sh
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

MAX_NAME = 64
ALLOWED_RESOURCES = {"scripts", "references", "assets"}
DEFAULT_ROOT = Path.home() / ".agents" / "skills"


def slugify_check(name: str, enforce_the: bool) -> str | None:
    if not re.match(r"^[a-z0-9]+(-[a-z0-9]+)*$", name):
        return f"name '{name}' must be lower-kebab-case"
    if len(name) > MAX_NAME:
        return f"name too long ({len(name)} > {MAX_NAME})"
    if enforce_the and not name.startswith("the-"):
        return (
            f"name '{name}' must start with 'the-'. pass --no-the-prefix to override."
        )
    return None


def render_skill_md(
    name: str,
    description: str,
    compatible_tools: list[str],
    category: str,
    test_prompts: list[str],
) -> str:
    escaped_description = description.replace('"', '\\"')
    tools_list = ", ".join(compatible_tools)
    prompts = test_prompts or ["TODO: realistic user prompt"]
    prompts_block = "\n".join(f"  - {json.dumps(p)}" for p in prompts)

    title = name.replace("-", " ").title()

    return (
        "---\n"
        f"name: {name}\n"
        f'description: "{escaped_description}"\n'
        f"compatible-tools: [{tools_list}]\n"
        f"category: {category}\n"
        "test-prompts:\n"
        f"{prompts_block}\n"
        "---\n"
        "\n"
        f"# {title}\n"
        "\n"
        "TODO: one-line purpose statement.\n"
        "\n"
        "## When to Use\n"
        "\n"
        "TODO: specific trigger contexts, file types, user phrases.\n"
        "\n"
        "## When Not to Use\n"
        "\n"
        "TODO: cases where a simpler approach wins.\n"
        "\n"
        "## Workflow\n"
        "\n"
        "TODO: step-by-step procedure, decision tree, or capability list.\n"
        "Pick the structure that fits:\n"
        "- **Workflow-Based** for sequential procedures (step 1 -> step 2 -> ...)\n"
        "- **Task-Based** for tool collections (task A, task B, task C)\n"
        "- **Reference** for standards or specifications\n"
        "- **Capabilities-Based** for integrated feature systems\n"
        "\n"
        "## Done Definition\n"
        "\n"
        'TODO: what "this skill applied correctly" looks like.\n'
    )


def init_skill(args: argparse.Namespace) -> int:
    name = args.skill_name
    err = slugify_check(name, enforce_the=not args.no_the_prefix)
    if err:
        print(f"error: {err}", file=sys.stderr)
        return 1

    root = Path(args.root).expanduser()
    skill_dir = root / name

    if skill_dir.exists():
        print(f"error: {skill_dir} already exists", file=sys.stderr)
        return 1

    resources = set()
    if args.resources:
        for res in args.resources.split(","):
            res = res.strip()
            if res not in ALLOWED_RESOURCES:
                print(
                    f"error: unknown resource '{res}'. allowed: {sorted(ALLOWED_RESOURCES)}",
                    file=sys.stderr,
                )
                return 1
            resources.add(res)

    compatible_tools = [t.strip() for t in args.compatible_tools.split(",") if t.strip()]

    skill_dir.mkdir(parents=True, exist_ok=False)
    (skill_dir / "SKILL.md").write_text(
        render_skill_md(
            name=name,
            description=args.description,
            compatible_tools=compatible_tools,
            category=args.category,
            test_prompts=args.test_prompts,
        )
    )

    for res in resources:
        (skill_dir / res).mkdir()
        (skill_dir / res / ".gitkeep").touch()

    print(f"created {skill_dir}")
    print()
    print("next steps:")
    print(f"  1. edit {skill_dir}/SKILL.md to fill TODOs")
    print(
        f"  2. validate: python3 ~/.agents/skills/the-skill-creator/scripts/quick_validate.py {skill_dir}"
    )
    print(f"  3. sync to claude/codex: bash ~/.agents/scripts/sync-skills.sh")
    print(f"  4. update ~/.agents/skills/INDEX.md")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("skill_name")
    parser.add_argument("--root", default=str(DEFAULT_ROOT))
    parser.add_argument(
        "--description",
        default="TODO: what the skill does and when it should trigger.",
    )
    parser.add_argument(
        "--resources",
        default="",
        help="comma-separated: scripts,references,assets",
    )
    parser.add_argument(
        "--compatible-tools",
        default="claude,codex",
    )
    parser.add_argument(
        "--category",
        default="workflow",
        help=(
            "lower-kebab-case slug; common values: workflow, ui, review, safety, "
            "planning, development, architecture, cli, discovery"
        ),
    )
    parser.add_argument(
        "--test-prompts",
        nargs="*",
        default=[],
    )
    parser.add_argument(
        "--no-the-prefix",
        action="store_true",
        help="allow skill names that don't start with 'the-'",
    )
    args = parser.parse_args()
    return init_skill(args)


if __name__ == "__main__":
    sys.exit(main())
