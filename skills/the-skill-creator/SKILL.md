---
name: the-skill-creator
description: "Create, rewrite, evaluate, and tighten reusable skills. Use whenever the user wants to turn a workflow into a skill, merge or improve existing skills, refine skill triggering/frontmatter, add scripts/references/assets, or test whether a skill actually performs better. For new skills created with this skill, default the folder name and frontmatter name to the-SLUG unless the user explicitly asks for another name."
compatible-tools: [claude, codex]
category: workflow
test-prompts:
  - "create a new skill"
  - "새 스킬 만들어줘"
  - "turn this workflow into a skill"
  - "스킬 업데이트해줘"
  - "이 스킬 트리거가 잘 안 걸려, 개선해줘"
---

# The Skill Creator

Build skills that are small, trigger-clear, and worth loading.

## Scope

- New skill creation.
- Rewriting, merging, or tightening existing skills.
- Fixing triggering (frontmatter) or bloat (body length).
- Adding scripts, references, or assets only when they save repeated work.
- Forward-testing a skill via realistic prompts, not demo prompts.

## Progressive Disclosure

Skills load on demand, so each artifact has a budget:

1. **Tier 1 — discovery**: `name` + `description` only. The harness matches these against the user prompt. If they miss, the body never loads.
2. **Tier 2 — body**: `SKILL.md` body is read when the skill triggers. Keep it lean and procedural. Link out for anything heavy.
3. **Tier 3 — on-demand**: `scripts/`, `references/`, `assets/` load only when the body tells the agent to read or execute them.

Write for that budget. If content is not needed every trigger, push it to Tier 3.

## Anti-list

Do not create any of these unless the user explicitly asks:

- `README.md`, `INSTALLATION.md`, `QUICK_REFERENCE.md`, `CHANGELOG.md`
- `agents/openai.yaml` or other UI metadata files
- Placeholder empty folders (`scripts/`, `references/`, `assets/`)
- Multiple overlapping sample files that duplicate body content
- `.gitkeep` in folders with real files

`SKILL.md` is the source of truth. Everything else exists only if it pulls its weight.

## Naming

- Folder name equals frontmatter `name`.
- Lowercase letters, digits, hyphens only. Max 64 chars.
- New skills default to `the-SLUG`. Keep the slug short and intent-shaped (`the-build-fixer`, `the-pr-reviewer`).
- Prefer a verb-led phrase in the description's first sentence (`Diagnose and fix...`, `Turn a Slack thread into...`).
- Tool-namespace only when the skill is tool-specific (`vercel-react-best-practices` is fine because it targets one vendor's guidelines). Otherwise keep names tool-agnostic.
- If updating an existing skill, preserve the name unless the user asks for a rename.

## Degrees of Freedom

Choose how prescriptive the skill should be before drafting the body:

- **High freedom (heuristic)** — reviewing, brainstorming, code smell hunting. Give principles and rationale, not steps.
- **Medium freedom (patterned)** — common workflows with variant paths. Give the default path and call out forks.
- **Low freedom (scripted)** — fragile procedures, API calls, formatting requirements. Give strict steps or delegate to `scripts/`.

A too-loose skill underperforms on deterministic jobs; a too-tight skill fights with real context. Pick the minimum that keeps the job reliable.

## Creation Flow

1. **Clarify the job.** One sentence: who triggers this, with what input, to produce what output.
2. **Scaffold** with the helper:
   ```
   python3 ~/.agents/skills/the-skill-creator/scripts/init_skill.py the-SLUG \
     --description "trigger-shaped description" \
     --resources scripts,references \
     --test-prompts "prompt 1" "prompt 2"
   ```
   Use `--no-the-prefix` only for ports of third-party skills.
3. **Decide freedom level** (above) and pick the body structure:
   - workflow-based (step 1 → 2 → 3)
   - task-based (task A, task B, task C)
   - reference (spec or standards)
   - capabilities-based (integrated feature map)
4. **Write frontmatter first.** The `description` is the only Tier-1 surface; it must name the job, the triggers, and the inputs. Slightly assertive, not keyword-stuffed.
5. **Write a lean body.** Cut anything the agent already knows. Keep rationale over shouting.
6. **Add Tier-3 files only if used.**
   - `scripts/` — deterministic work that would otherwise be rewritten per run.
   - `references/` — long specs, tables, or schemas the body should link to, not inline.
   - `assets/` — templates the skill outputs or copies.
7. **Validate.**
   ```
   python3 ~/.agents/skills/the-skill-creator/scripts/quick_validate.py <skill-dir>
   ```
   Use `--strict-naming` for new skills to enforce `the-` prefix.
8. **Forward-test** with realistic prompts (see next section).
9. **Sync.** The Claude `PostToolUse` and Codex `SessionStart` hooks run `~/.agents/scripts/sync-skills.sh` automatically. Run it manually only if you need the symlink farm rebuilt right now.
10. **Update `~/.agents/skills/INDEX.md`** with the new entry.

## Forward Testing

Don't trust a skill until a fresh-context agent triggers it on realistic prompts.

- Collect 3-5 prompts that represent the real trigger surface, in the languages the user will actually use.
- Run each through a new agent session (e.g. an `Explore` or `general-purpose` subagent) and check:
  1. Did the skill fire at all?
  2. Did it fire at the right time, or did a nearer-surface tool win?
  3. Did the body actually guide the work, or did the agent ignore it?
- If triggering fails, fix the description first. Rewriting the body rarely fixes Tier-1 miss.
- If triggering works but the body wastes tokens, push bulk detail into `references/` and reference it on demand.
- Do not overfit to a 3-prompt set. Look for the shape of the failures, not the exact wording.

## Updating Existing Skills

Find the real bottleneck before rewriting:

- **Not firing** → tighten `description` triggers.
- **Firing too late** → add concrete phrases and file types it should match on.
- **Body bloat** → move long examples, tables, or specs into `references/`.
- **Repeated boilerplate** → bundle it into `scripts/`.
- **Unclear workflow** → restructure as numbered steps or a capability table.

Change the smallest thing that fixes the real failure. Don't refactor what already works.

## Evaluation Guidance

- Objective output (code generation, parsing, deterministic tasks): run 2-5 realistic prompts, compare against the previous skill version, a simpler prompt, or no skill at all.
- Subjective output (writing, planning, judgment): use a lighter feedback loop with the user, not synthetic scores.
- Look for process quality too: if the skill causes the agent to write the same helper every run, the helper belongs in `scripts/`.
- Generalize from failure patterns; never hardcode a rescue for a single test case.

## Done Definition

- Folder contains only what is used. No empty `scripts/`, no unreferenced `references/`.
- Frontmatter validates clean (`quick_validate.py`).
- `description` names the job and the trigger phrases explicitly.
- Body is the minimum guidance that makes the skill reliable at its freedom level.
- At least one forward-test run confirms the skill fires on realistic prompts, or the user has accepted that the task is too subjective to benchmark.
- `~/.agents/skills/INDEX.md` reflects the change.
