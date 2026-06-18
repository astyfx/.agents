---
name: the-sparkler-to-sbdashboard
description: "Convert Sparkler Storybook design proposals into sbdashboard-ready implementation plans and code. Use when the user wants to use ~/workspaces/Sparkler instead of Figma, translate Sparkler Product/Projects stories, CSS modules, or Dash DS components into sbdashboard screens, or map Sparkler design intent to sbdashboard's Feather/UI primitives, React Query hooks, and styling conventions."
compatible-tools: [claude, codex]
category: ui
test-prompts:
  - "Use the Sparkler Voice Configuration Settings story to implement the matching sbdashboard screen"
  - "Convert this Sparkler project story into a sbdashboard implementation plan"
  - "Use Sparkler instead of Figma for this sbdashboard design handoff"
---

# The Sparkler to sbdashboard Bridge

Use Sparkler as a code-readable design source, then re-express the result in
sbdashboard's own architecture, components, tokens, and verification habits.

## When to Use

- The design source is a Sparkler Storybook story under
  `~/workspaces/Sparkler/stories/product` or `stories/projects`.
- The user mentions Sparkler, Dash DS, Storybook review source, Product/Project
  stories, or using Sparkler instead of Figma for a sbdashboard screen.
- The task is to implement, plan, or review a sbdashboard change based on a
  Sparkler design proposal.

## When Not to Use

- The source is an actual Figma file or screenshot only. Use
  `the-design-cloner`.
- The task is to improve Sparkler itself. Use Sparkler's repo-local `AGENTS.md`.
- The sbdashboard task is logic-only and has no design handoff.

## Workflow

### 1. Resolve the Design Source

In Sparkler, read only the files needed for the requested story:

1. `AGENTS.md` for Sparkler's source-of-truth rules.
2. `docs/component-catalog.md` for Dash DS component vocabulary.
3. `public/review-source/manifest.json` when the user gives a Storybook review
   source link or a story title.
4. The matching `*.stories.tsx` and companion `*.module.css`.
5. `src/tokens/tokens.json` only when token intent is unclear.

Treat Sparkler stories as design intent, state matrix, and interaction notes.
Do not import Sparkler packages, CSS modules, Tailwind classes, or lucide icons
into sbdashboard.

### 2. Load the sbdashboard Target Rules

Before planning implementation in `~/workspaces/sbdashboard`, read:

1. `AGENTS.md`.
2. `AGENTS.local.md` if it exists.
3. Any `AGENTS.md` under the target path, plus:
   - `app/feather/AGENTS.md` for Feather primitives.
   - `app/ui/components/AGENTS.md` for Dashboard UI helpers.
   - `app/ui/components/dialog/AGENTS.md` when dialogs are involved.

If the target is Aero settings, integrations, webhooks, channels, or Evaluate,
search adjacent features first and prefer their file split: API/queryOptions in
`app/Aero/api`, page orchestration in `index.tsx`, feature hooks in `hooks/`,
view fragments in `components.tsx`, custom visual CSS in `styled.tsx`, and local
types/constants where the feature already uses them.

### 3. Extract the Sparkler Design Contract

Create a compact translation brief before editing code:

```md
## Sparkler Source
- Story: <path/title>
- Companion CSS: <path>
- Product vs Project: <which mode>

## Intent
- User goal:
- Product behavior:
- Non-goals:

## State Matrix
- Controls/args:
- Loading/empty/error:
- Permission/environment:
- Dirty/saving/success/validation:

## Surface Anatomy
- Shell/regions:
- Forms and controls:
- Tables/lists:
- Dialogs/panels:
- Copy and helper text:
```

Prefer explicit state names from the Storybook args and `parameters.review`
description over visual guessing.

### 4. Translate Components, Do Not Copy Them

Map Sparkler concepts to sbdashboard primitives:

| Sparkler / Dash DS | sbdashboard target |
|---|---|
| `Button`, `IconButton` | Feather button/icon button or existing local action component |
| `Input`, `Textarea`, `Select`, `Combobox`, `Switch`, `Checkbox`, `Radio`, `Slider` | Existing Feather/UI form controls already used in the target domain |
| `Dialog`, `FullPageDialog`, `SidePanel` | Global dialog registry, `@ui/components/dialog`, drawer, or feature-local panel per existing pattern |
| `PageHeader`, `SettingsSection`, `SettingsSideNav`, `SidebarNav` | Existing settings layout, `Flex`, feature components, or sbdashboard navigation helpers |
| `Badge`, `Dot`, status marks | Feather badge/lozenge/tag or existing status component |
| `Table`, `Pagination`, `Tabs`, `Tooltip` | Existing Feather/UI table, paginator, tabs, tooltip patterns |
| lucide icons or Sparkler SVGs | Existing `SBi*` icons; add generated Sendbird icon assets only if the repo pattern requires it |
| Sparkler CSS variables/Tailwind/CSS modules | `cssVariables()`, `Fonts`, `Flex.Row`/`Flex.Column`, and feature-local styled-components |

Never carry over raw colors, Tailwind classes, CSS modules, `var(--color-*)`,
Gellix/Pretendard font decisions, or lucide imports. Explain any deliberate
visual deviation from Sparkler in terms of sbdashboard tokens and components.

### 5. Plan the sbdashboard Implementation

After reading the target code, produce a short implementation plan:

```md
## sbdashboard Mapping
- Target route:
- Existing peer files:
- Components to reuse:
- API/query/mutation hooks:
- Dialog/store wiring:
- Translations/copy:
- Tests:

## Open Questions
- New token/component needed?
- Behavior not represented in Sparkler?
- Existing pattern vs better pattern tradeoff?
```

Ask before adding a new shared primitive, changing Feather/UI component APIs,
introducing a new token, or choosing a better architecture that conflicts with
the local pattern. For routine implementation choices, proceed with the
sbdashboard rules.

### 6. Implement in sbdashboard

Use the narrowest code change that satisfies the translated design:

- Keep Sparkler's state coverage, but use sbdashboard's actual stores, API
  contracts, permissions, environment gates, and route params.
- Use React Query `queryOptions` and mutation patterns for server state.
- Use `react-hook-form` and existing validation patterns for forms.
- Do not create layout-only styled wrappers; use `Flex.Row`, `Flex.Column`, and
  `Fonts` where the root rules require them.
- Keep custom visual styling feature-local unless it belongs in a shared
  component by existing repo criteria.
- Add focused tests when behavior, regression risk, or state transitions justify
  them; avoid incidental coverage churn.

### 7. Verify and Report

Use verification that matches the change:

- For planning-only work, return the translation brief and implementation plan.
- For code changes, run focused tests or story/dev-server checks that match the
  repo policy. Do not auto-run broad lint/type checks in sbdashboard unless the
  user asks or the PR creation procedure requires it.
- When visual confidence matters and local servers are available, compare the
  Sparkler story and sbdashboard screen with screenshots, then list intentional
  differences.

## Done Definition

- Sparkler source files and sbdashboard target rules were both inspected.
- The response or implementation includes a Sparkler-to-sbdashboard mapping,
  not a direct copy of Sparkler code.
- sbdashboard code uses local components, tokens, hooks, routing, dialogs, and
  tests consistent with repo-local `AGENTS.md` files.
- Any unresolved design/product ambiguity is called out as an open question.
