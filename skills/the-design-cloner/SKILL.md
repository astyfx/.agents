---
name: the-design-cloner
description: "Faithfully clone a visual reference (Figma frame, website, design-system component) into code by inspecting the source, extracting real tokens, and verifying with screenshots, so output matches the reference not just looks similar. Triggers '이 디자인 그대로 구현', '피그마 그대로', 'clone this Figma frame', 'replicate this UI'."
compatible-tools: [claude, codex]
category: ui
test-prompts:
  - "이 피그마 디자인 그대로 구현해줘"
  - "clone this website hero section"
  - "copy this shadcn dialog exactly"
  - "reference Linear's sidebar and match it"
  - "이 사이트 레이아웃 베껴서 만들어줘"
  - "replicate this component from Radix"
  - "Sentry 대시보드처럼 똑같이 만들어줘"
  - "match this Figma frame pixel-accurate"
---

# The Design Cloner

Reproduce a visual reference accurately. Not "inspired by", not "similar feel" —
the output should be visually indistinguishable from the source at the same
viewport and theme.

## Use This Skill When

- The user provides a Figma URL, website URL, screenshot, or library component
  and wants the result to match it.
- A Figma design handoff: implement the frame as production code and verify it
  against the source ("피그마 구현해줘", "implement this Figma design").
- Words like "그대로", "똑같이", "exactly", "pixel-accurate", "clone", "replicate",
  "copy", "reference and match" appear in the request.
- Close-but-off results would be a failure (e.g. brand landing page, marketing
  hero, design-system parity).

## Do Not Use This Skill When

- The user wants "inspired by" or a loose riff on a style (use `the-frontend-director`).
- There is no concrete source to compare against.
- The task is pure logic with no visual target.

## Why AI Usually Fails At This

Typical failure modes to actively guard against:

1. **Eyeballing from a thumbnail** — writing CSS from memory of a screenshot.
2. **Inventing tokens** — using `#3b82f6` when the real value is `#2563EB`.
3. **Collapsing spacing** — padding `16px` when the source uses `20px` / `12px` asymmetric.
4. **Wrong type scale** — `text-base` for a `15px / 22px` label.
5. **Missing states** — hover, focus, disabled, empty.
6. **Skipping verification** — declaring done without a side-by-side compare.

The whole point of this skill is to block those shortcuts.

## Workflow

### Step 1 — Identify the source type and ingest it

Pick the right extraction path:

| Source | Preferred tool | Fallback |
|---|---|---|
| Figma URL | Figma MCP (`mcp__figma__*`) — get frame, styles, variables | Screenshot + careful reading of style panel |
| Live website | Playwright / Stave Lens (`stave_lens_navigate` + `stave_lens_get_html`, `stave_lens_screenshot`, `stave_lens_evaluate`) | `WebFetch` + manual inspection |
| shadcn/Radix/library component | Read the source from the upstream repo or `node_modules` | Screenshot with props variants |
| Screenshot only | Zoom and annotate; request a link if possible before guessing |

**Never** start coding from a single thumbnail when a higher-fidelity source is reachable.

### Step 2 — Extract real tokens

Before writing any JSX/CSS, produce a token table.

```
## Extracted Tokens
Colors:
  - primary.bg:    #0A0A0A  (from .hero background)
  - primary.fg:    #F5F5F5  (from h1 color)
  - accent:        #2563EB  (from cta button)
Typography:
  - display:       Inter Display 48/56, weight 600, -0.02em tracking
  - body:          Inter 15/22, weight 400
Spacing (source-measured):
  - section-y:     96px
  - card-pad-x:    20px
  - card-pad-y:    16px
  - gap:           12px
Radii: 8 / 12 / 999
Shadow: 0 1px 2px rgba(0,0,0,.08), 0 8px 24px rgba(0,0,0,.12)
```

How to get each:

- **Figma**: read the style panel / variables. Copy values, do not retype by eye.
- **Website**: `getComputedStyle` via `stave_lens_evaluate` on the exact element.
- **Library**: read the component source (tailwind classes, CSS vars).

### Step 3 — Map layout geometry

Describe the layout as a grid/flex tree with measured constraints before coding:

```
<section py=96 max-w=1200 mx=auto>
  <grid cols=12 gap=24>
    <col span=6>
      <stack gap=24>
        <eyebrow />
        <h1 />        // 48/56
        <p />         // 15/22, max-w=520
        <row gap=12>
          <primary-cta />
          <secondary-cta />
        </row>
      </stack>
    </col>
    <col span=6 align=center>
      <media aspect=16/10 radius=12 shadow=lg />
    </col>
  </grid>
</section>
```

This prevents "it's sort of two columns" guesses.

### Step 4 — Implement in the target stack

Match the project's conventions:

- Tailwind project → use existing theme tokens. If a token is missing, add it
  to `tailwind.config` / `globals.css` rather than hardcoding.
- shadcn project → prefer shadcn primitives over hand-rolled markup.
- Design tokens file → extend it; never bypass.

One component at a time. Ship the outer shell first, then fill children.

### Step 5 — Side-by-side verification (required)

This is the non-negotiable step.

1. Render the implementation (dev server, preview route, or a Storybook story)
   at the reference viewport width (e.g. 1440).
2. Screenshot it (Playwright or `stave_lens_screenshot`).
3. Place reference and implementation side by side.
4. Diff against the token table and the layout map.
5. For Figma references, verify at 100% zoom against the frame.

Report the comparison:

```
## Verification
Viewport: 1440 × 900, light theme
Reference: <link>
Implementation: <screenshot>

Diffs found:
  - section-y is 88px, should be 96px → fix
  - cta hover: missing shadow transition → fix
  - body text: rendering at 16px, source is 15px → fix

Diffs accepted (with reason):
  - font smoothing differs (browser vs Figma renderer) — accepted
```

### Step 6 — States and responsiveness

Don't stop at the default state. Verify:

- hover, focus-visible, active, disabled
- empty / loading / error if applicable
- dark mode if the reference has one
- at least two breakpoints (e.g. 1440 and 768)

### Step 7 — Done check

Do not declare done until:

- Token table is committed (inline comment or design-tokens file).
- Layout matches the map within 2px / 2%.
- All states verified.
- Side-by-side screenshot captured and diffs resolved or consciously accepted.

## Common Traps

- **Auto-layout ≠ flex**. Figma auto-layout with "fill" can mean `flex-1` OR a
  fixed width. Read the constraint, do not guess.
- **Figma blur/shadow values** are in px at the frame's resolution; translate to
  CSS units directly.
- **Font metrics** differ between Figma's rendering and the browser. Use
  `font-feature-settings`, `font-smoothing`, and exact `line-height` to close
  the gap.
- **Gradients** often hide a dithering layer or noise overlay — check the layer
  stack, not just the top fill.

## Integration with Other Skills

- `the-design-tokens`: when the values you extract should become a structured,
  reusable token system rather than one-off hardcoded values.
- `the-frontend-director`: use after cloning when the user wants additional
  product-design judgment layered on top.
- `shadcn-ui`: use when the clone should sit on top of shadcn primitives.
- `the-theme-token-sync`: use when the clone introduces new tokens that must
  propagate through the app theme.

## Done Definition

- Token table extracted from the real source (not memory).
- Layout map produced before coding.
- Implementation matches reference at target viewport within tolerance.
- Side-by-side screenshot comparison done and reported.
- States and at least two breakpoints covered.
