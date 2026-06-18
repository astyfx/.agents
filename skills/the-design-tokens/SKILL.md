---
name: the-design-tokens
description: "Build or extend a coherent design-token system for any product - the structure, naming, scales, and theming method behind colors, typography, spacing, radius, shadow, z-index, and motion. Use when setting up tokens for a new design system, adding a role/scale-step/dark-mode/surface to an existing token set, or refactoring scattered hardcoded values into tokens. Triggers: '디자인 토큰 만들어', '토큰 정리해줘', 'color scale 잡아줘', 'type scale', 'spacing system', '테마 구조 잡아줘', 'design tokens', 'set up a token system', 'build a color scale', 'design system foundations'. This skill teaches the METHOD; the product's brand and existing system decide the actual values - it never imports a fixed palette, scale, or font from memory."
compatible-tools: [claude, codex]
category: ui
test-prompts:
  - "디자인 토큰 시스템 잡아줘"
  - "color scale 만들어줘"
  - "type scale랑 spacing 정리해줘"
  - "이 하드코딩된 색들 토큰으로 정리해줘"
  - "dark mode 토큰 추가해줘"
  - "set up design tokens for this project"
  - "build a coherent color system"
  - "refactor these inline values into tokens"
---

# The Design Tokens

Tokens are the contract between design intent and code. This skill is about the
*method* of structuring, naming, scaling, and verifying a token system - not a
fixed palette, scale, or font. The product's brand and existing system decide the
values. You decide the structure and process, and you keep it coherent.

## Use this skill when

- Setting up token foundations for a new design system or product.
- Extending an existing token set: a new color role, a scale step, dark mode,
  a new surface or status, a new elevation.
- Refactoring scattered hardcoded hex / px / rem values into a token system.
- The user says "토큰 정리", "color scale 잡아줘", "type scale", "spacing system",
  "design tokens", "theme 구조".

## Skip when

- Editing existing token *values* where the risk is drift across presets and
  built-in themes → use [the-theme-token-sync](../the-theme-token-sync/SKILL.md).
- Applying tokens while writing component CSS → use [the-css-craft](../the-css-craft/SKILL.md).
- Reproducing one reference's exact values pixel-for-pixel → use [the-design-cloner](../the-design-cloner/SKILL.md).

## Prime directive: never invent a parallel system

Most products already have tokens. Your job is to extend them coherently, not to
drop a second system beside the first. Before defining anything:

1. Find the existing token source (theme file, CSS custom properties, Tailwind
   config, a tokens package). [the-css-craft](../the-css-craft/SKILL.md) lists
   where these live per repo.
2. Read the existing naming convention, tiers, and scales. Match them.
3. Only add what is missing, in the tier and vocabulary the project already uses.

If there is genuinely no system yet, build one with the method below - seeded
from the product's brand and references, never from your training defaults.

## No imported defaults

This is the rule that makes the skill portable. The references in this file
explain *how* to reason about a scale or a contrast target. They are not values
to paste in.

- Do not introduce a font (Inter, Geist, Roboto...) the product has not declared.
- Do not pick brand hues from memory. Take the seed from the product's logo,
  brand, or an explicit reference.
- Do not copy a competitor's spacing or type numbers. Derive the product's own.
- When you need a concrete number, derive it from the product's base unit and a
  stated ratio, or lift it from the reference - then write down where it came from.

## The method

### 1. Three tiers, one direction

Structure tokens in up to three tiers, consumed in one direction only:

- **Primitive** (raw values): the full ramp of a value type. `color.blue.600`,
  `space.4`, `font.size.300`. No meaning, just the palette of available values.
- **Semantic** (roles): what a value is *for*. `color.text.muted`,
  `color.surface.raised`, `color.border.focus`, `space.inline.sm`. Semantic
  tokens reference primitives.
- **Component** (optional): per-component overrides when a component needs to
  diverge. `button.primary.bg`. References semantic tokens.

The one rule that makes theming work: **components consume semantic tokens, never
primitives directly.** When a component uses `color.text.muted`, switching
themes or dark mode is a change at the semantic layer, not a hunt through every
component. If the project is small, semantic-only is fine; do not add tiers it
does not need.

When the project needs a serializable, tool-agnostic format (handoff to Style
Dictionary, multi-platform export), the DTCG format is the interchange standard:
each token carries an explicit `$value` and `$type`. Use it when there is a
pipeline that consumes it; do not add the ceremony for a single-app CSS-variable
setup.

### 2. Name by role, not by value

- `--color-text-muted`, not `--gray-500`.
- `--space-inset-md`, not `--padding-16`.
- `--radius-control`, not `--radius-6`.

Values change; roles do not. A value-based name (`--gray-500`) becomes a lie the
moment the theme shifts or dark mode inverts it. Derive role names from the
product's own vocabulary - if the codebase says `surface`, do not introduce
`background`; if it says `accent`, do not introduce `brand`.

### 3. Build each scale as a system, not a pile

A scale is a small, evenly-reasoned set - not an open-ended grab bag. For each:

- **Color**: derive a stepped ramp per hue from the brand seed. Use a
  perceptually-uniform space (OKLCH) where the toolchain allows, so steps feel
  evenly spaced and lightness is predictable across hues - this is why a raw HSL
  ramp looks uneven. Assign roles by contrast intent (text, UI, borders,
  hover/active), and verify each text/background pairing against a contrast
  *target* you must meet (WCAG 2.2 contrast minimums, or APCA where the project
  uses it) - the target is the standard, the exact hex is derived. Keep light and
  dark in role-parity (see step 4). Do not default to indigo/violet because it is
  the easy choice; take the hue from the product.
- **Type**: one scale with a consistent ratio between steps. Pair each size with
  a line-height and an allowed weight set so type is chosen as a role
  ("body", "heading.lg") not an arbitrary px. Use `clamp()` for fluid type when
  the product wants responsive headings. Use the product's font; do not import one.
- **Spacing**: one base unit and a consistent progression (commonly a doubling or
  a fixed-step ramp). Every margin, padding, and gap snaps to the scale. No
  one-off `padding: 13px 17px`.
- **Radius**: a few role-based steps (control, card, pill/full), not a value per
  component.
- **Shadow / elevation**: define shadows as elevation *roles* (raised, overlay,
  popover), not ad-hoc blur values - elevation should read as a consistent system.
- **Z-index**: named layers (base, dropdown, sticky, overlay, modal, toast), not
  magic numbers competing across files.
- **Motion**: duration and easing tokens by role (see
  [the-motion-design](../the-motion-design/SKILL.md) for how to choose them).

Refactoring UI is the right reference for *why* a constrained scale and clear
hierarchy beat hand-picked values. Material 3 and Tailwind are useful as examples
of scale *structure* - not as the numbers to copy.

### 4. Theming and dark mode live at the semantic layer

- The semantic layer is what a theme swaps. Primitives stay; their semantic
  mapping changes.
- **Role parity is mandatory**: every semantic token defined in one theme must be
  defined in every theme. A token present in light but missing in dark is a
  silent visual bug. (For stave's enumerated token-name lists, this is exactly
  what [the-theme-token-sync](../the-theme-token-sync/SKILL.md) guards.)
- Dark mode is a token state, not a per-component hand-wire. If you are setting
  dark colors inside a component, the token system is incomplete - fix the token.
- Prefer `color-scheme` and a single theme switch over scattered dark: classes.

### 5. Extend without drift

When adding a token:

1. Decide its tier (almost always semantic).
2. Add it to **every** theme/preset, in role-parity.
3. If the project enumerates token names in a types file or list, update that
   source too (or the token is invisible to tooling).
4. Reuse an existing primitive if one fits; add a primitive only if the ramp
   genuinely lacks the value.

## Done checklist

- [ ] Existing token system found and matched; no parallel system introduced.
- [ ] Components reference semantic tokens, not primitives or raw values.
- [ ] Names describe roles, not values.
- [ ] Each scale (color, type, space, radius, shadow, z, motion) is a consistent
      system, not a pile of one-offs.
- [ ] Every text/surface color pair meets the project's contrast target.
- [ ] Light and dark (and every preset) have full role parity - no missing tokens.
- [ ] New tokens are registered everywhere the project tracks token names.
- [ ] No font, palette, or scale was imported from memory; values trace to the
      product or a named reference.
- [ ] No orphan tokens (defined, never used) left behind.

## Anti-patterns

- A second token system dropped next to the existing one.
- Primitives leaking into components (`color.blue.600` in a button).
- Value-based names (`--gray-500`, `--padding-16`) that lie after a theme change.
- Per-component one-off colors instead of a shared role.
- Dark mode hand-wired in components instead of driven by tokens.
- A "scale" with inconsistent jumps between steps.
- An imported default font or brand hue the product never chose.

## See also

- [the-theme-token-sync](../the-theme-token-sync/SKILL.md) - drift prevention when editing existing token values (stave)
- [the-css-craft](../the-css-craft/SKILL.md) - applying tokens while writing component CSS
- [the-design-cloner](../the-design-cloner/SKILL.md) - extracting real values from a reference
- [the-motion-design](../the-motion-design/SKILL.md) - motion duration/easing tokens
- [the-frontend-director](../the-frontend-director/SKILL.md) - overall aesthetic direction

## Method references

These ground the *reasoning*, not the values:

- DTCG design tokens format (`$value` / `$type`, interchange): https://www.designtokens.org/
- Style Dictionary DTCG pipeline: https://styledictionary.com/info/dtcg/
- Radix Colors - 12-step scale composition and roles: https://www.radix-ui.com/colors
- OKLCH for perceptually-even color ramps: https://evilmartians.com/chronicles/oklch-in-css-why-quit-rgb-hsl
- WCAG 2.2 contrast minimum: https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html
- APCA contrast model (where used): https://git.apcacontrast.com/documentation/WhyAPCA.html
- Refactoring UI - scale, hierarchy, and color reasoning: https://www.refactoringui.com/
