---
name: shadcn-ui
description: Use when adding or updating shadcn/ui components, forms, dialogs, tables, or theme primitives in React apps. Prefer generating components with the shadcn CLI, preserving project aliases, and syncing semantic tokens instead of hand-writing copied wrappers. Good for Tailwind, Radix, Zod form work, and design-system-safe UI changes.
compatible-tools: [claude, codex]
category: ui
test-prompts:
  - "shadcn 컴포넌트 추가"
  - "dialog를 shadcn으로 바꿔줘"
  - "form field를 shadcn 규칙으로 정리"
---

# shadcn/ui Guardrails

Use shadcn/ui as generated project code, not as a generic copy-paste snippet source.

## Prefer

- `bunx --bun shadcn@latest add <component>` over hand-writing wrappers
- existing project aliases such as `@/...`
- semantic tokens over raw hardcoded colors
- Radix composition patterns already used by the generated component

## Avoid

- `npx` or `npm` examples when the project uses Bun
- pasting external snippet imports without reconciling aliases
- adding a custom wrapper before checking whether shadcn already provides the primitive
- hardcoding colors that should be theme tokens

## Workflow

1. Check whether the project already has the component.
2. If not, generate it with `bunx --bun shadcn@latest add <component>`.
3. Reconcile imports to the repo alias scheme.
4. If the component introduces or relies on semantic tokens, verify the theme token system.
5. Keep business logic outside the UI primitive where possible.

## Forms

- use React Hook Form with Zod when validation is non-trivial
- keep schema and field names aligned
- keep submit/loading/error states explicit
- prefer accessible labels, descriptions, and messages

## Theme and Tokens

If the change touches colors, surfaces, or preset behavior:

- check `globals.css`
- check theme token definitions
- check built-in themes
- check `@theme inline`

Do not treat a shadcn preset change as complete until theme sync is verified.

## Output

Return:

- component generated vs reused
- import alias fixes applied
- token or theme sync required
- accessibility or form-state verification still required
