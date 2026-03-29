---
name: the-figma-to-code
description: Convert Figma designs to production-ready code with visual verification. Use when the user says "피그마 구현해줘", "implement this Figma design", "디자인 코드로 변환", or provides a Figma URL/reference for implementation. Uses Figma MCP for design extraction and Playwright for visual comparison.
compatible-tools: [claude, codex]
category: ui
test-prompts:
  - "피그마 구현해줘"
  - "implement this Figma design"
  - "디자인 코드로 변환"
  - "convert this Figma to React"
---

# The Figma-to-Code Skill

Figma design → production-ready code with visual verification loop.

## Use This Skill When

- The user provides a Figma URL, frame name, or screenshot for implementation.
- The user says "피그마 구현", "implement this design", "디자인 → 코드".
- A design handoff is happening and pixel-accurate implementation is needed.

## Do Not Use This Skill When

- The user wants UI built from scratch without a design reference (use the-frontend-director).
- The user is asking about Figma tool usage, not code implementation.

## Prerequisites

- **Figma MCP**: configured in settings for design extraction (or Figma screenshot provided).
- **Project framework**: React + Tailwind + shadcn/ui (default stack).
- **Playwright**: installed for visual verification (optional but recommended).

## Workflow

### Step 1 — Extract Design Specification

If Figma MCP is available:
1. Fetch the component/frame structure from Figma.
2. Extract design tokens: colors, spacing, typography, border radius.
3. Identify component hierarchy and layout (flex, grid, absolute).
4. Note interactive states (hover, active, disabled, focus).
5. List assets needed (icons, images).

If Figma MCP is not available (screenshot provided):
1. Analyze the screenshot visually.
2. Infer layout, spacing, colors, and typography.
3. Ask the user to clarify ambiguous elements.

Output:
```
## Design Spec
- **Layout**: {flex/grid/absolute, direction, alignment}
- **Colors**: {list of colors used with CSS values}
- **Typography**: {font families, sizes, weights}
- **Spacing**: {padding, margin, gap values}
- **Components**: {identified components and their hierarchy}
- **States**: {hover, active, disabled, focus behaviors}
```

### Step 2 — Implement Components

Use the-frontend-director principles:
1. Build from smallest component up (atoms → molecules → organisms).
2. Use shadcn/ui base components where applicable.
3. Use Tailwind utility classes for styling.
4. Implement responsive breakpoints if the design shows them.
5. Add accessibility attributes (ARIA labels, keyboard nav).

### Step 3 — Visual Verification Loop

After initial implementation:

1. **Render**: Start the dev server or create a Storybook story.
2. **Capture**: Take a screenshot using Playwright:
   ```typescript
   await page.goto('http://localhost:3000/component-preview');
   await page.screenshot({ path: 'current.png' });
   ```
3. **Compare**: Side-by-side comparison with the Figma reference.
4. **Checklist**:
   ```
   ## Visual Verification
   - [ ] Layout matches (flex direction, alignment, spacing)
   - [ ] Colors match (backgrounds, text, borders)
   - [ ] Typography matches (font, size, weight, line-height)
   - [ ] Spacing matches (padding, margin, gap)
   - [ ] Border radius matches
   - [ ] Interactive states work (hover, focus, active)
   - [ ] Responsive behavior matches breakpoints
   ```
5. **Fix**: Address mismatches and re-verify.
6. **Iterate**: Repeat until all checklist items pass.

### Step 4 — Polish & Handoff

1. Ensure component is properly typed (TypeScript props interface).
2. Add brief JSDoc for the component's purpose and props.
3. Verify the component works in isolation and in context.
4. Report implementation status to the user.

## Output Format

```
## Figma Implementation: {component name}

### Files Created/Modified
- `src/components/{name}.tsx` — main component
- `src/components/{name}.stories.tsx` — storybook (if applicable)

### Design Tokens Applied
- Colors: {mapped}
- Typography: {mapped}
- Spacing: {mapped}

### Visual Verification
{checklist with results}

### Notes
- {any deviations from design and why}
- {responsive behavior decisions}
```

## Done Definition

The implementation is complete when:
- All visual verification checklist items pass.
- Component is properly typed and accessible.
- The user confirms the implementation matches the design intent.
