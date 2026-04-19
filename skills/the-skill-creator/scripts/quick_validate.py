#!/usr/bin/env python3
"""Validate a skill directory for the ~/.agents harness.

Checks SKILL.md:
- exists and starts with YAML frontmatter
- frontmatter is a valid YAML dict
- required keys: name, description
- optional keys: compatible-tools, category, test-prompts, license,
  allowed-tools, metadata, user-invocable
- name is hyphen-case, <= 64 chars, starts with `the-` when a brand-new skill
- description has no angle brackets, <= 1024 chars
- category (optional) is a lower-kebab-case slug

Usage:
    quick_validate.py <skill-dir> [--strict-naming]

`--strict-naming` enforces the `the-<slug>` convention for new skills. Omit it
for pre-existing skills that intentionally break the convention (e.g. third-
party ports like `ai-elements`).
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

MAX_NAME = 64
MAX_DESCRIPTION = 1024


def _unquote(value: str) -> str:
    value = value.strip()
    if len(value) >= 2 and value[0] == value[-1] and value[0] in ("'", '"'):
        inner = value[1:-1]
        if value[0] == '"':
            inner = inner.replace('\\"', '"').replace("\\\\", "\\")
        return inner
    return value


def _parse_inline_list(raw: str) -> list[str]:
    raw = raw.strip()
    if not (raw.startswith("[") and raw.endswith("]")):
        raise ValueError(f"expected inline list, got: {raw}")
    inner = raw[1:-1].strip()
    if not inner:
        return []
    return [_unquote(item) for item in inner.split(",")]


def _indent_of(line: str) -> int:
    return len(line) - len(line.lstrip(" "))


def parse_frontmatter(text: str) -> dict:
    """Parse the subset of YAML frontmatter used across harness skills.

    Supports:
      key: value                       -> str
      key: "quoted value"              -> str
      key: [a, b, c]                   -> list[str]
      key: >-                          -> folded block scalar (str)
        line one
        line two
      key: |                           -> literal block scalar (str)
      key:                             -> list[str] (- items) or dict (sub keys)
        - item1
        - "item 2"
    Nested mappings (e.g. metadata:) are parsed as opaque dicts.
    """
    result: dict[str, object] = {}
    lines = text.splitlines()
    i = 0
    n = len(lines)
    key_re = re.compile(r"^(\s*)([A-Za-z][A-Za-z0-9_\-]*)\s*:\s*(.*)$")
    item_re = re.compile(r"^(\s+)-\s*(.*)$")

    def parse_block(start: int, base_indent: int):
        """Return (value, next_index) for a block under a keyless header."""
        # Detect block: block list or mapping.
        j = start
        # Skip blanks/comments to peek.
        while j < n and (not lines[j].strip() or lines[j].lstrip().startswith("#")):
            j += 1
        if j >= n:
            return None, start
        peek = lines[j]
        indent = _indent_of(peek)
        if indent <= base_indent:
            return None, start
        if peek.lstrip().startswith("- "):
            items: list[str] = []
            k = j
            while k < n:
                nxt = lines[k]
                if not nxt.strip() or nxt.lstrip().startswith("#"):
                    k += 1
                    continue
                im = item_re.match(nxt)
                if not im or _indent_of(nxt) != indent:
                    break
                items.append(_unquote(im.group(2)))
                k += 1
            return items, k
        # Mapping block: collect sub-keys at this indent.
        mapping: dict[str, object] = {}
        k = j
        while k < n:
            nxt = lines[k]
            if not nxt.strip() or nxt.lstrip().startswith("#"):
                k += 1
                continue
            if _indent_of(nxt) < indent:
                break
            if _indent_of(nxt) > indent:
                # Skip deeper content we don't need for validation.
                k += 1
                continue
            sm = key_re.match(nxt)
            if not sm:
                break
            sub_key = sm.group(2)
            sub_rest = sm.group(3).strip()
            if sub_rest == "":
                sub_val, k2 = parse_block(k + 1, indent)
                mapping[sub_key] = sub_val if sub_val is not None else ""
                k = k2
                continue
            if sub_rest.startswith("["):
                mapping[sub_key] = _parse_inline_list(sub_rest)
            else:
                mapping[sub_key] = _unquote(sub_rest)
            k += 1
        return mapping, k

    def parse_block_scalar(start: int, base_indent: int, fold: bool) -> tuple[str, int]:
        collected: list[str] = []
        k = start
        first_indent: int | None = None
        while k < n:
            nxt = lines[k]
            if not nxt.strip():
                collected.append("")
                k += 1
                continue
            indent = _indent_of(nxt)
            if indent <= base_indent:
                break
            if first_indent is None:
                first_indent = indent
            collected.append(nxt[first_indent:])
            k += 1
        if fold:
            # Folded: join non-empty lines with spaces; blank lines -> newline.
            out: list[str] = []
            buf: list[str] = []
            for part in collected:
                if part == "":
                    if buf:
                        out.append(" ".join(buf))
                        buf = []
                    out.append("")
                else:
                    buf.append(part)
            if buf:
                out.append(" ".join(buf))
            return "\n".join(out).strip(), k
        return "\n".join(collected).rstrip(), k

    while i < n:
        raw = lines[i]
        if not raw.strip() or raw.lstrip().startswith("#"):
            i += 1
            continue
        m = key_re.match(raw)
        if not m:
            raise ValueError(f"cannot parse line: {raw!r}")
        indent = len(m.group(1))
        if indent != 0:
            # Top-level parse should not encounter indented keys here.
            i += 1
            continue
        key, rest = m.group(2), m.group(3).strip()

        if rest in (">", ">-", "|", "|-"):
            fold = rest.startswith(">")
            value, i = parse_block_scalar(i + 1, indent, fold=fold)
            if rest.endswith("-"):
                value = value.rstrip("\n")
            result[key] = value
            continue

        if rest == "":
            value, i = parse_block(i + 1, indent)
            if value is None:
                raise ValueError(f"key '{key}' has no value")
            result[key] = value
            continue

        if rest.startswith("["):
            result[key] = _parse_inline_list(rest)
        else:
            result[key] = _unquote(rest)
        i += 1

    return result
ALLOWED_KEYS = {
    "name",
    "description",
    "compatible-tools",
    "category",
    "test-prompts",
    "license",
    "allowed-tools",
    "metadata",
    "user-invocable",
}
ALLOWED_TOOLS = {"claude", "codex", "amp"}
# Category is a free-form taxonomy hint; we only require it be a lower-kebab
# slug so the INDEX can group skills without spelling drift.
CATEGORY_RE = re.compile(r"^[a-z0-9]+(-[a-z0-9]+)*$")


def fail(msg: str) -> tuple[bool, str]:
    return False, msg


def validate(skill_dir: Path, strict_naming: bool = False) -> tuple[bool, str]:
    skill_md = skill_dir / "SKILL.md"
    if not skill_md.exists():
        return fail(f"SKILL.md not found in {skill_dir}")

    content = skill_md.read_text()
    match = re.match(r"^---\n(.*?)\n---", content, re.DOTALL)
    if not match:
        return fail("missing or malformed YAML frontmatter")

    fm_text = match.group(1)
    try:
        fm = parse_frontmatter(fm_text)
    except ValueError as exc:
        return fail(f"invalid YAML in frontmatter: {exc}")

    unexpected = set(fm) - ALLOWED_KEYS
    if unexpected:
        return fail(
            f"unexpected frontmatter key(s): {sorted(unexpected)}. "
            f"allowed: {sorted(ALLOWED_KEYS)}"
        )

    for required in ("name", "description"):
        if required not in fm:
            return fail(f"missing required key: {required}")

    name = str(fm["name"]).strip()
    if not re.match(r"^[a-z0-9]+(-[a-z0-9]+)*$", name):
        return fail(f"invalid name '{name}' (must be lower-kebab-case)")
    if len(name) > MAX_NAME:
        return fail(f"name too long: {len(name)} > {MAX_NAME}")
    if strict_naming and not name.startswith("the-"):
        return fail(
            f"name '{name}' must start with 'the-' under --strict-naming"
        )

    description = str(fm["description"]).strip()
    if not description:
        return fail("description is empty")
    if "<" in description or ">" in description:
        return fail("description contains angle brackets (< or >)")
    if len(description) > MAX_DESCRIPTION:
        return fail(f"description too long: {len(description)} > {MAX_DESCRIPTION}")

    tools = fm.get("compatible-tools")
    if tools is not None:
        if not isinstance(tools, list) or not tools:
            return fail("compatible-tools must be a non-empty list")
        bad = set(map(str, tools)) - ALLOWED_TOOLS
        if bad:
            return fail(
                f"compatible-tools contains unknown values: {sorted(bad)}. "
                f"known: {sorted(ALLOWED_TOOLS)}"
            )

    category = fm.get("category")
    if category is not None:
        if not isinstance(category, str) or not CATEGORY_RE.match(category):
            return fail(
                f"invalid category '{category}' (must be lower-kebab-case slug)"
            )

    test_prompts = fm.get("test-prompts")
    if test_prompts is not None:
        if not isinstance(test_prompts, list):
            return fail("test-prompts must be a list of strings")
        if not all(isinstance(p, str) and p.strip() for p in test_prompts):
            return fail("test-prompts entries must be non-empty strings")

    dir_name = skill_dir.resolve().name
    if dir_name != name:
        return fail(f"directory name '{dir_name}' does not match skill name '{name}'")

    return True, f"OK: {name}"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("skill_dir", type=Path)
    parser.add_argument("--strict-naming", action="store_true")
    args = parser.parse_args()

    ok, msg = validate(args.skill_dir, strict_naming=args.strict_naming)
    print(msg)
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
