---
name: the-improvement-loop
description: Iterative scored improvement — implement, measure, refine until a quality threshold is met. Use when the user says "반복 개선해줘", "improve until good enough", "keep refining", "score and improve", or when quality needs to be driven up through measured iteration rather than a single pass.
compatible-tools: [claude, codex]
category: workflow
test-prompts:
  - "반복 개선해줘"
  - "score and improve this"
  - "keep refining until it's good"
  - "improvement loop"
---

# The Improvement Loop

Scored iterative refinement: implement → measure → refine → repeat until threshold.

## Use This Skill When

- The user wants quality driven up through measurable iteration.
- The user says "반복 개선", "keep improving", "score and refine".
- A single-pass implementation is unlikely to meet quality requirements.
- Applicable domains: code quality, test coverage, performance, UI polish, accessibility.

## Do Not Use This Skill When

- The task has a clear, one-shot solution (just implement it).
- The user wants TDD specifically (use the-tdd instead).
- There is no measurable quality criterion.

## Core Concepts

### Rubric

A rubric defines what is being measured and what "good enough" means.
Every improvement loop starts by defining or selecting a rubric.

```
Rubric: {name}
Dimensions:
  - {dimension-1}: {description} (weight: {1-5})
  - {dimension-2}: {description} (weight: {1-5})
Threshold: {target score, e.g., 80/100}
Max iterations: {default 5}
```

### Scoring

Each dimension is scored 0-20 (or 0-100 for single-dimension rubrics).
Weighted total produces the iteration score.
The delta between iterations shows whether refinement is working.

## Workflow

### Step 1 — Define Rubric

Either use a preset rubric or create one from the user's goals.

**Preset rubrics:**

| Name | Dimensions | Default threshold |
|---|---|---|
| code-quality | Correctness, Readability, DRY, Error handling, Type safety | 80 |
| test-coverage | Happy path, Failure path, Edge cases, Integration, Isolation | 80 |
| performance | Load time, Bundle size, Re-render count, Memory, Responsiveness | 75 |
| ui-polish | Visual accuracy, Responsiveness, Accessibility, Interactions, Consistency | 80 |
| accessibility | ARIA, Keyboard, Contrast, Screen reader, Focus management | 85 |

**Custom rubric**: Ask the user to define dimensions, weights, and threshold.

### Step 2 — Initial Implementation

Create the first version. This is the baseline.

- If code exists, assess as-is (no implementation step needed).
- If starting fresh, make a reasonable first pass.
- Run the relevant scoring mechanism (tests, lighthouse, manual assessment).

### Step 3 — Score (Iteration N)

Score each dimension. Be honest and specific.

```
## Iteration {N} Score

| Dimension | Score | Notes |
|---|---|---|
| {dim-1} | {score}/20 | {specific evidence} |
| {dim-2} | {score}/20 | {specific evidence} |
| ... | ... | ... |
| **Total** | **{weighted-total}/{max}** | Delta: {+/-} from last |
```

Scoring must be evidence-based:
- **Code quality**: cite specific lines, patterns
- **Test coverage**: run tests, report pass/fail/coverage %
- **Performance**: run benchmarks, report metrics
- **UI polish**: take screenshots, compare with reference
- **Accessibility**: run axe/lighthouse, report violations

### Step 4 — Analyze Delta

After scoring:
1. Compare with previous iteration (or baseline).
2. Identify the lowest-scoring dimensions — these are the targets.
3. If delta is negative or zero for 2 consecutive iterations, change strategy.
4. If delta is positive but below threshold, continue refinement.

### Step 5 — Refine

Make targeted improvements on the lowest-scoring dimensions:
- Fix one dimension at a time to isolate impact.
- Document what was changed and why.
- Avoid regressing dimensions that already score well.

### Step 6 — Loop or Exit

**Exit when:**
- Total score ≥ threshold → report final score and summary
- Max iterations reached → report best iteration and remaining gaps
- All dimensions individually above acceptable floor (threshold × 0.6 per dimension)

**Continue when:**
- Score is below threshold AND delta is positive AND iterations remain

### Step 7 — Final Report

```
## Improvement Loop: {rubric-name}

Iterations: {N}
Starting score: {baseline}
Final score: {final}
Threshold: {threshold}
Result: ✅ Passed / ⚠️ Best effort (max iterations)

### Score Progression
| Iteration | Score | Delta | Key change |
|---|---|---|---|
| 1 | {score} | — | Baseline |
| 2 | {score} | {delta} | {what changed} |
| ... | ... | ... | ... |

### Remaining Gaps
- {gap-1}: scored {X}/{max}, needs {description of what would improve it}

### Recommendations
- {next steps if score did not reach threshold}
```

## Integration with Other Skills

- **the-tdd**: use for test-coverage rubric (TDD cycle as the implementation method)
- **the-code-reviewer**: use review axes as scoring dimensions for code-quality rubric
- **the-frontend-director**: use for UI implementation in ui-polish rubric
- **the-build-fixer**: invoke when iteration introduces build errors

## Guardrails

- Never change the rubric mid-loop to inflate scores.
- Never skip the scoring step — every iteration must be measured.
- If the user adjusts the threshold mid-loop, restart scoring from the current state.
- Report honestly: a low score with clear gaps is more useful than an inflated pass.

## Done Definition

The improvement loop is complete when:
- Final score is reported with evidence.
- Score progression is documented.
- Either threshold was met or max iterations exhausted with best-effort explanation.
- Remaining gaps (if any) have actionable recommendations.
