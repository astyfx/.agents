# Eval 15: Figma-to-Code Implementation

## Objective

Test the agent's ability to implement a Figma design as a React component with visual verification.

## Prompt

> Implement this Figma design as a React + Tailwind component. Verify it matches visually.

## Setup

- Provide a Figma screenshot or MCP reference for a medium-complexity component (card, form, dashboard widget).
- Component should have: layout, colors, typography, at least one interactive state.

## Expected Behavior

1. Agent extracts design spec (layout, colors, typography, spacing).
2. Agent implements as React + Tailwind + shadcn/ui component.
3. Agent performs visual verification (checklist or screenshot comparison).
4. Agent reports any deviations from design with rationale.

## Scoring

- **pass**: Component matches design, all checklist items verified, code is clean and typed.
- **partial**: Component mostly matches but has visible deviations, or no visual verification.
- **no**: Implementation does not match design, or skipped design extraction entirely.

## Rubric Dimensions

- Design spec extraction (layout, colors, typography, spacing identified)
- Component implementation quality (clean, typed, uses shadcn/ui)
- Visual verification execution (checklist completed, deviations documented)
- Responsive behavior (breakpoints handled if applicable)
- Accessibility (ARIA labels, keyboard navigation)
