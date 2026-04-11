# Figma Design to Implementation and Visual Verification

## Trigger

Use when a user provides a Figma frame, URL, or screenshot and wants
production-ready UI implementation with explicit visual verification.

## Inputs

- Figma URL, frame id, or screenshot
- target codebase and UI surface to implement
- whether Figma MCP and Playwright are available
- existing design system constraints in the target repo

## Required Tools

- `the-figma-to-code`
- `the-frontend-director` when implementation quality and product polish matter
- Figma MCP if available, otherwise screenshot analysis
- local preview or Storybook surface
- Playwright or an equivalent screenshot/checklist path for visual verification

## Steps

1. Confirm the implementation target:
   - exact frame/component
   - destination codebase or file area
   - whether this is a one-off component or part of a larger screen
2. Extract or infer the design spec:
   - layout and hierarchy
   - colors, typography, spacing, radius, shadows
   - interactive states and responsive behavior
3. Map the design to the existing repo patterns before writing code:
   - current component system
   - existing tokens and primitives
   - any established accessibility or layout conventions
4. Implement the component or screen with the narrowest reasonable file set.
5. Run a visual verification loop:
   - render the implemented surface
   - compare against the Figma reference or screenshot
   - list concrete mismatches
   - iterate until the visible gaps are resolved or explicitly documented
6. Report the final status with:
   - files changed
   - what matched exactly
   - any deliberate deviations and why
7. If the work spans sessions, roll the current state into `work-handoff.md`
   and the active durable task artifact.

## Expected Artifacts

- implementation patch in the target repo
- design-spec summary or extracted tokens
- visual verification checklist or screenshot-comparison notes
- documented deviations when a perfect match is not practical

## Verification

- confirm the implemented surface matches the intended frame, not just the
  general style
- verify the layout and spacing before polishing secondary details
- make sure responsive or interaction behavior is checked when the design
  implies it
- record whether the verification came from screenshot comparison, checklist,
  or both

## Rollback Notes

- do not claim visual match without an explicit comparison step
- if MCP extraction is unavailable, say which details were inferred
- if the target repo has a stronger existing design system, follow it and note
  any necessary deviation from the raw Figma spec
