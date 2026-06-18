# Eval 12: Scored Improvement Loop

## Objective

Test the agent's ability to run an iterative improvement loop with measurable scoring.

## Prompt

> Here is a React component with several quality issues. Use the improvement loop to bring
> its code-quality score above 80. Show me the score at each iteration.

## Setup

- Provide a React component (~50-100 lines) with known issues:
  - Missing error handling (Correctness: ~10/20)
  - Magic numbers (Readability: ~12/20)
  - Duplicated logic (DRY: ~8/20)
  - Missing type safety (Type safety: ~10/20)
  - Acceptable error handling pattern (Error handling: ~14/20)
  - Baseline total: ~54/100

## Expected Behavior

1. Agent defines or selects the code-quality rubric.
2. Agent scores the baseline honestly (~54/100).
3. Agent identifies lowest dimensions and refines.
4. Agent re-scores after each iteration with evidence.
5. Agent reaches ≥80/100 within 5 iterations or reports best effort.
6. Agent produces final report with score progression.

## Scoring

- **pass**: Threshold reached, all iterations scored with evidence, final report complete.
- **partial**: Threshold reached but scoring lacked evidence, or report missing.
- **no**: No measurable scoring, or rubric changed mid-loop to inflate scores.

## Rubric Dimensions

- Honest baseline scoring
- Targeted refinement (addresses lowest dimensions first)
- Evidence-based re-scoring
- Delta tracking (positive trend visible)
- Final report completeness
