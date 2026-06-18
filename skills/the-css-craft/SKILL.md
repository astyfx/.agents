---
name: the-css-craft
description: "Write modern CSS/UI that respects the project's design system and reference, avoiding invented colors/fonts and AI-slop tropes. Use when writing styles, translating a screenshot/Figma to components, modernizing dated CSS, or the user says it shouldn't look AI-generated ('더 모던하게', 'less AI-generated', '올드하지 않게')."
compatible-tools: [claude, codex]
category: ui
test-prompts:
  - "이 스타일 좀 더 모던하게 정리해줘"
  - "스크린샷처럼 만들어줘"
  - "이 CSS 좀 다듬어줘"
  - "이 컴포넌트 예쁘게 만들어줘"
  - "make this component feel less AI-generated"
  - "clean up this CSS to feel modern"
  - "이 레퍼런스대로 구현해줘 (but not pixel-perfect)"
  - "dashboard UI를 올드하지 않게 바꿔줘"
---

# The CSS Craft

Rules for writing UI that feels intentional, modern, and rooted in the project's actual design system — not AI-generated from memory.

## Use this skill when

- Writing or editing CSS / styled-components / Tailwind / CSS Modules for product UI in any repo.
- The user gives a reference (screenshot, Figma, URL, existing component) and expects the result to respect it — even if not pixel-perfect.
- Modernizing old-feeling UI or CSS.
- The user says the output feels generic, AI-generated, dated, or "튀어나가서 이상한걸 만들었다".

## Skip when

- Pure pixel-accurate clone of a single reference → use [the-design-cloner](../the-design-cloner/SKILL.md).
- Picking the overall aesthetic direction from scratch for greenfield work → use [the-frontend-director](../the-frontend-director/SKILL.md).
- Token / theme changes across presets and built-in themes → use [the-theme-token-sync](../the-theme-token-sync/SKILL.md).
- Adding shadcn components by CLI → use [shadcn-ui](../shadcn-ui/SKILL.md).
- Figma handoff or pixel-accurate clone → use [the-design-cloner](../the-design-cloner/SKILL.md).
- Building or extending a token system → use [the-design-tokens](../the-design-tokens/SKILL.md).
- Motion / transitions / micro-interactions → use [the-motion-design](../the-motion-design/SKILL.md).
- Accessible interactive components (keyboard, focus, ARIA) → use [the-a11y-components](../the-a11y-components/SKILL.md).

These skills overlap on topic but not on operating mode. This one is the background rulebook while you write CSS.

## The three rules

1. Ground every visual decision in context that exists — the project, or the user's reference.
2. Use modern CSS. Not 2019 CSS.
3. No AI-slop visual tropes.

Each rule has a section below.

---

## 1. Ground in context

Your training data is not a design system. It is a pile of average websites. Defaulting to it produces average websites.

### Order of truth

When picking any visual value — color, spacing, radius, font, shadow, motion — use this order and stop at the first hit:

1. **The user's reference** (screenshot, Figma frame, URL, attached code). Extract actual values.
2. **The project's tokens / theme files** (listed per project below).
3. **A visually-adjacent project component** whose pattern you can reuse.
4. **A modern CSS primitive** (oklch for color extension, clamp for type, color-mix for hover) — never a guess.
5. Ask. Inventing is worst.

### The tree is a menu, not the meal

When the user points you at a repo or folder, listing files is not enough. Read the theme tokens, read the component file, lift the exact hex / px / rem / font-weight. Writing CSS from your memory of what "Linear sidebars look like" produces a generic look-alike. The real values are sitting in the file — read them.

### Match the visual vocabulary

Before writing a new component in an existing codebase, look at a representative peer and copy its idiom. Specifically match:

- copy tone (terse / playful / formal), capitalization (sentence / title / ALL CAPS)
- palette usage (which tokens appear, which are reserved for accents vs. neutrals)
- density (is this a comfortable or compact product?)
- shadow and card style (flat / layered / bordered / elevated)
- hover / active / focus-visible pattern
- motion style (instant / 120ms ease / spring)
- border-radius scale (is everything rounded? sharp? mixed-by-role?)

If you are adding a surface and the rest of the product is restrained, your surface is also restrained. A loud new component in a quiet product is wrong even if it is beautiful in isolation.

### Project-specific quick reference

#### sbdashboard (`~/workspaces/sbdashboard`)

- **CSS approach**: styled-components with CSS variables from `@feather/theme/cssVariables`. Do not introduce Tailwind, Emotion, or CSS Modules.
- **Theme tokens**: `app/feather/theme/cssVariables.ts`, `app/feather/themes.ts`, `app/ui/styles/theme.ts`.
- **Fonts**: `app/ui/fonts/sbfonts.css` — Avenir Next + system fallback. Do not reach for Inter / Roboto.
- **Icons**: Sendbird icon system at `app/feather/components/icons/svg/` (prefix `SBi*`, e.g. `SBiPlusCircle`). No lucide / heroicons.
- **Primitives**: `app/ui/components/` (e.g. `Flex`, `Fonts`, `TextWithIcon`, `ApplicationDropdown`).
- **Read first**: a representative peer like `app/ui/components/ApplicationDropdown.tsx` to see cssVariables + icon + styled-component idiom.

#### stave (`~/workspaces/stave`)

- **CSS approach**: Tailwind v4 + shadcn/ui on top of CSS custom properties in `oklch()` color space. Variants via `class-variance-authority`.
- **Theme tokens**: `src/globals.css` (60+ custom props), `src/lib/themes/types.ts` (`THEME_TOKEN_NAMES`, `EXTENDED_THEME_TOKEN_NAMES`), `src/lib/themes/presets.ts`, `src/lib/themes/builtin-themes.ts`.
- **Fonts**: variable Geist, variable Inter, JetBrains Mono, Nunito, Pretendard (KR). Use `font-mono` / `font-sans` classes, not a Google Font import from memory.
- **Icons**: lucide-react only.
- **Primitives**: `src/components/ui/` (shadcn wrappers with CVA), `src/components/layout/` (stave-specific surfaces).
- **Read first**: `src/components/ui/button.tsx` (CVA pattern) and `src/globals.css` (token names in use). When touching tokens, also invoke [the-theme-token-sync](../the-theme-token-sync/SKILL.md).

#### dui (`~/workspaces/dui`)

- **CSS approach**: plain semantic CSS files per package. No Tailwind, no utility classes, no styled-components, no CSS-in-JS. Class naming `dui-[component]`, modifiers `is-*`, state via `data-*` attributes on the element.
- **Theme tokens**: `packages/tokens/src/tokens.js` (semantic names: `brand`, `surface`, `text`, `border`, `status`), `packages/tokens/src/tokens.css` (light + dark).
- **Foundations**: `packages/css-foundations/src/` — reset, base, utilities. Style additions must live here or in a component package, not inline.
- **Dependency direction**: `tokens → css-foundations → primitives → components → apps`. One way. Never import downstream.
- **Primitives vs. components**: headless behavior at `packages/primitives/src/`, styled versions at `packages/components/src/`. Never style a primitive directly; wrap it.
- **Read first**: `packages/tokens/src/tokens.js` for the semantic token map, then any component in `packages/components/src/` for the CSS naming convention.

---

## 2. Modern CSS primitives

Default to current-era CSS. Reach for older patterns only when the modern one does not exist or is blocked by support requirements.

### Prefer → Avoid

| Prefer | Over |
|---|---|
| CSS custom properties / project tokens | hardcoded hex, px, rem sprinkled into components |
| `oklch()` and `color-mix()` for variants | hand-picked hex for each hover / disabled state |
| `clamp()` for type and spacing | media-query ladder for font sizes |
| `text-wrap: balance` (headlines) / `text-wrap: pretty` (body) | JS to fit text |
| `gap` on flex / grid containers | `margin-right` on all children, `:last-child { margin-right: 0 }` |
| CSS Grid with `grid-template-areas` / subgrid | nested flex pretending to be a grid |
| Container queries (`@container`) for component-local responsive | viewport media queries for component internals |
| `aspect-ratio` | padding-top hacks |
| Logical properties (`inline-size`, `margin-block`) | left/right assumptions that break on RTL |
| `:focus-visible` outlines | `outline: none` with no replacement |
| `@layer` for cascade control | selector specificity wars and `!important` |
| `color-scheme: light dark` + media-query dark mode | hand-wiring dark mode class toggles when CSS can do it |
| `scroll-margin` / `scroll-snap` | JS scroll handlers |
| `:has()` for parent-state styling | extra classes / React state toggles |

### Hard lines

- No `!important` unless there is a specific cross-origin / third-party reason. Comment why.
- No `z-index` higher than 50 without a reason documented in a comment.
- No `overflow: hidden` as a crutch for a layout bug you didn't diagnose.
- No hover styles without `@media (hover: hover)` guard on touch-relevant surfaces.
- No fixed pixel body type below 14px. No tap targets below 44px.
- No `<br>` for spacing.

### If the project already sets a convention, the project wins

dui's CSS Modules-free rule overrides the table above where they conflict. Match the project's approach; modern does not mean "rewrite the architecture".

---

## 3. No AI-slop visual tropes

The default LLM UI has a look. Ship this look and the user will know. The list below is not exhaustive — it is the most common.

### Defaults to refuse

- Purple-to-pink or indigo-to-cyan gradient backgrounds on cards, heroes, or chrome. Unless the brand uses them. It almost never does.
- Cards with a coloured left-border accent + rounded corners + inner pill. This is the AI "stat card" default. Reach for the project's card instead.
- Glassmorphism / frosted-glass backdrops. Unless the brand uses them.
- Inter, Roboto, Arial, Fraunces, "Geist" reached for by name when the project has not declared it. Use the project's font stack. Do not `@import` a Google Font without checking.
- Emoji in UI copy, icons, or empty-states, unless the project already uses emoji.
- Decorative SVG drawn by you — illustrations, abstract shapes, "hero graphics". Use the project's icon set for icons. For illustrations, placeholder box + label and ask.
- Fake data density: grids of 6+ "stat cards" with invented numbers and up-arrow deltas. If the screen needs stats, the user will tell you which stats.
- Placeholder Lorem ipsum or marketing-voice fillers ("Transform your workflow", "The future of X"). Leave blank or ask.
- Dark-mode-by-accident: dark surface + default lucide icons in stock color + a generic "tech" vibe with no grounding. Dark mode is a token-driven state, not an aesthetic choice you make by hand.
- Shadows larger than the project uses. A card that feels like it's floating in an otherwise flat product is wrong.

### Content discipline

- Do not pad a design with extra sections, stat cards, testimonials, FAQs, or decorative "AI explanation" blocks to fill vertical space. Empty space is a design, not a bug.
- Do not invent metrics, names, quotes, logos.
- If the design looks empty and that bothers you, ask the user what belongs there — do not guess.
- Match the product's existing copy voice. If buttons in the app say "Save", don't write "Save changes now".

### "But it looks fine" test

Before declaring the UI done, answer honestly:

- If you removed every gradient, rounded left-border card, and emoji, would it still work? If not, the fallback design is weak — fix that, not the decoration.
- Does every element earn its place? If you deleted it, would anyone notice?
- Would a designer at the target reference's company (Linear, Sentry, Stripe, Vercel, whoever the project is modeled on) ship this?

---

## When the user gives a clear reference

The most frequent failure is drifting from a reference the user explicitly gave you. Follow this order. Do not skip a step because "it looks close enough".

1. **Ingest the reference fully.** Read the code / open the Figma / view the image at full size. Not the thumbnail.
2. **Extract exact values** — color hexes, spacing numbers, border-radius, font family + weight + size + line-height, shadow values, motion durations. Write them down in a comment or scratch file if helpful.
3. **Map each extracted value to the nearest project token**. If the project has a token within ~5-10% and the visual difference will not be noticed, use the token. If the reference specifies a value outside the token scale and the user wants faithfulness, call it out and propose either a one-off with a comment or a new token.
4. **Build with the project's existing primitives** where the reference has an equivalent (buttons, inputs, dialogs, cards). Only fall back to raw CSS when the project has no primitive for that pattern.
5. **Spot-check**. Screenshot your output next to the reference at the same zoom. Look specifically at: padding, type sizes, color of neutrals (this is where AI drifts most), border treatment, state (hover / active / focus-visible).
6. **If you decide to deviate from the reference, say so explicitly**. "I used `--surface-default` instead of the reference's `#f3f4f6` because the project's neutral is cooler" is acceptable. Silent deviation is not.

### Do not

- Re-invent the layout because "this grid is cleaner".
- Re-pick the color because "this contrasts better" — if the reference picked it, the user knows.
- Add sections, illustrations, icons, or copy the reference doesn't have.
- Round values to "nicer" numbers (18px → 16px, 13px → 14px). If the reference says 18, write 18 or a token that equals 18.

For pixel-accurate clones specifically (brand landing, design-system parity), stop here and invoke [the-design-cloner](../the-design-cloner/SKILL.md) — it has a stricter verification loop.

---

## Final checklist before done

Run this list mentally before saying a UI change is complete.

- [ ] Every color / spacing / type value traces back to a token, a reference value, or a modern CSS primitive (oklch / clamp / color-mix). Nothing from memory.
- [ ] Fonts are the project's declared fonts. No Inter / Roboto / Fraunces smuggled in.
- [ ] Icons are the project's icon set (SBi* / lucide / whatever). No hand-drawn SVG unless asked.
- [ ] Hover, active, focus-visible, disabled, empty states are all present. Focus-visible is visible.
- [ ] No `!important`, no z-index > 50 without a comment, no `outline: none` without replacement.
- [ ] No AI-slop tropes (gradient chrome, left-border accent cards, glass, decorative SVG, emoji, fake stats).
- [ ] Dark mode works because the tokens handle it, not because you hand-wired it.
- [ ] Spacing uses the project's scale. No one-off `padding: 13px 17px`.
- [ ] Body type ≥ 14px, tap targets ≥ 44px, line-height ≥ 1.4 on paragraphs.
- [ ] If a reference was given, each deliberate deviation from it is named out loud.
- [ ] Nothing is padded with filler copy, placeholder stats, or inventive content to fill space.

---

## See also

- [the-frontend-director](../the-frontend-director/SKILL.md) — picking the aesthetic direction
- [the-design-cloner](../the-design-cloner/SKILL.md) — pixel-accurate reproduction and Figma handoff
- [the-design-tokens](../the-design-tokens/SKILL.md) — building / extending a token system
- [the-motion-design](../the-motion-design/SKILL.md) — motion and micro-interaction craft
- [the-a11y-components](../the-a11y-components/SKILL.md) — accessible interactive components
- [the-theme-token-sync](../the-theme-token-sync/SKILL.md) — token / theme cross-file sync (stave)
- [shadcn-ui](../shadcn-ui/SKILL.md) — shadcn CLI-based component addition
