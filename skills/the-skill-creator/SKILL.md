---
name: the-skill-creator
description: Create, rewrite, evaluate, and tighten reusable skills. Use whenever the user wants to turn a workflow into a skill, merge or improve existing skills, refine skill triggering/frontmatter, add scripts/references/assets, or test whether a skill actually performs better. For new skills created with this skill, default the folder name and frontmatter name to the-<slug> unless the user explicitly asks for another name.
---

# The Skill Creator

Build skills that are small, reusable, and worth triggering.

## Local Defaults

- Put new skills in the active skill root:
  - first choice: a skill directory explicitly named by the user
  - otherwise: the repo-local `skills/` folder if the task is project-specific
  - otherwise: the user's configured global skill folder
  - if still ambiguous, ask one concise question
- Treat `SKILL.md` as the source of truth.
- Do not create auxiliary docs like `README.md`, `CHANGELOG.md`, or install notes unless the user explicitly asks.
- Create optional folders only when they will be used:
  - `scripts/` for deterministic or repeated work
  - `references/` for detailed material that should be loaded on demand
  - `assets/` for templates or output resources
- Only create `agents/openai.yaml` if the target environment actually uses UI metadata. Skip it by default unless there is evidence it is needed.
- Match the user's language and jargon level. If the user is speaking Korean, default to Korean in the conversation. Keep skill files concise and usually in English unless the user wants otherwise.

## Naming Rule

- For new skills created with this skill, default the directory name and frontmatter `name` to `the-<slug>`.
- Keep the slug short, lowercase, and hyphenated.
- If the user is updating an existing skill, preserve the current name unless they explicitly ask for a rename.

## Working Stance

- Extract as much intent as possible from the current conversation, pasted drafts, or existing files before asking questions.
- If the user already has a draft skill, start from diagnosis and iteration instead of restarting from zero.
- Make reasonable assumptions and move forward. Ask only the questions that materially change the design.
- Assume the model is already capable. Add only the information that meaningfully improves reliability, triggering, or workflow fit.

## Creation Flow

1. Capture the job to be done.
2. Identify trigger contexts, expected outputs, examples, edge cases, dependencies, and success criteria.
3. Decide the degree of freedom:
   - high freedom for heuristic guidance
   - medium freedom for preferred patterns with some variation
   - low freedom for fragile workflows that need scripts or strict sequencing
4. Plan the minimal file set.
5. Draft or revise `SKILL.md`, especially the frontmatter description.
6. Add scripts, references, or assets only if they save repeated work or reduce failure modes.
7. Validate with realistic prompts when the task is objectively testable.
8. Iterate from failures without overfitting to a tiny prompt set.
9. Package, commit, or publish only if the user asks.

## Writing Rules

- Skill names use lowercase letters, digits, and hyphens only.
- The frontmatter `description` is the main trigger surface. It must include:
  - what the skill does
  - when to use it
  - concrete contexts or phrases that should trigger it
- Make the description slightly assertive so the skill does not undertrigger, but do not stuff unrelated keywords.
- Keep the body lean. Put bulky examples, schemas, or domain detail in `references/`.
- Prefer rationale over rigid shouting. If you feel tempted to write a wall of `ALWAYS` or `NEVER`, explain the reason instead.
- Avoid duplicating the same material across `SKILL.md` and bundled references.
- Do not create placeholder files or empty resource directories "just in case."

## Evaluation Guidance

- If the skill has objectively testable outputs, propose 2 to 5 realistic prompts and define what success looks like.
- Compare against a useful baseline when it helps:
  - no skill
  - the previous skill version
  - a simpler prompt-only approach
- Review process quality, not just final output. If the skill causes repeated script-writing, wasted reasoning, or awkward detours, either trim the prompt or bundle the repeated logic into `scripts/`.
- Generalize from failures. Do not hardcode brittle instructions that only rescue one test case.
- If the work is subjective, use a lighter evaluation loop with representative prompts and direct user feedback instead of pretending it is numerically benchmarkable.

## Updating Existing Skills

- Read the current skill first and find the real bottleneck:
  - weak triggering
  - bloated context
  - missing deterministic tooling
  - unclear workflow steps
  - poor fit for the user's actual prompts
- Tighten frontmatter before rewriting the whole body if the main issue is that the skill is not firing or is firing too late.
- If the same helper code keeps appearing across runs, write it once and bundle it.
- Keep what already works. Change the smallest thing that fixes the real failure.

## Done Definition

- The folder structure is minimal and intentional.
- `SKILL.md` is concise and trigger-clear.
- Optional resources are actually referenced and useful.
- The skill has been sanity-checked on realistic prompts, or the lack of evals is a conscious choice because the task is subjective.
