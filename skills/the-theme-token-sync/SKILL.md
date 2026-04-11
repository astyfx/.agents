---
name: the-theme-token-sync
description: Prevent theme token drift, missing built-in theme values, and silent visual regressions when editing globals.css, CSS custom properties, shadcn presets, or theme definitions. Use when changing color tokens, theme presets, built-in themes, or any UI surface that introduces or removes semantic tokens.
compatible-tools: [claude, codex]
category: safety
test-prompts:
  - "globals.css token 추가"
  - "theme preset 바꾸기"
  - "builtin theme 수정"
---

# The Theme Token Sync

Treat every UI token change as a cross-file theme change.

## Use This Skill When

- editing `globals.css` custom properties
- adding or renaming semantic color tokens
- changing `@theme inline`
- applying or reapplying a shadcn preset
- modifying built-in theme definitions
- introducing a new UI surface with its own semantic token

Do not use this skill for pure layout changes with no new token or theme behavior.

## Required Checklist

Check these files whenever a token changes:

1. `src/globals.css`
2. `src/lib/themes/types.ts`
3. `src/lib/themes/presets.ts`
4. `src/lib/themes/builtin-themes.ts`
5. `src/lib/themes/apply.ts`
6. `src/lib/themes/validate.ts`
7. `src/lib/themes/index.ts`
8. the `@theme inline` mapping in `src/globals.css`

Usually also check:

- `tests/custom-theme.test.ts`
- any touched UI surface that consumes the token

## Decision Tree

### Core token

If the token is part of shared UI chrome or shadcn semantics:

- add it to `THEME_TOKEN_NAMES`
- provide light and dark defaults in presets
- add it to every built-in theme
- wire it into `@theme inline`

### Extended token

If the token is for product surfaces such as editor, terminal, diff, charts, or provider accents:

- define it in light and dark base CSS
- add it to built-in themes
- wire it into `@theme inline`

It may not need to be a core token, but it still needs complete built-in theme coverage.

## Common Failure Example

"Dark High Contrast loses the new accent value" is the classic failure:

- token added to `:root`
- token added to `.dark`
- component looks fine in default theme
- one built-in theme forgot the token
- custom theme silently falls through to the wrong base value

This is a shipping bug even if TypeScript and screenshots on the default theme pass.

## Rename or Remove Flow

When removing or renaming a token:

1. update `globals.css`
2. update token name lists
3. update presets
4. update every built-in theme
5. update `@theme inline`
6. grep for old usages in components and utility classes

Search targets:

- `var(--old-token)`
- `bg-old-token`
- `text-old-token`
- `border-old-token`
- `ring-old-token`

## Guardrails

- never change `globals.css` tokens in isolation
- never assume built-in themes can fall through safely
- never stop after checking light and dark base mode only
- never change a preset without checking theme application and validation

## Verification

1. Run `bun run typecheck` if TypeScript modules changed.
2. Run the most relevant theme tests.
3. Manually inspect default light, default dark, and at least one built-in custom theme.

## Output

Return:

- token type: core or extended
- checklist files confirmed
- built-in themes touched
- grep targets still at risk
- verification completed vs still required

