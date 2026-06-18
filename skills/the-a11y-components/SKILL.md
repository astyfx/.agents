---
name: the-a11y-components
description: "Build accessible interactive UI components for any product - the keyboard, focus, semantics, and screen-reader contract behind menus, dialogs, comboboxes, tabs, tooltips, forms, and custom widgets. Use when implementing or fixing an interactive component, when keyboard or screen-reader support is missing or broken, or when an a11y/WCAG bar must be met. Triggers: '접근성 챙겨줘', '키보드 네비게이션', 'a11y', 'aria 추가', 'screen reader 대응', 'focus 관리', 'WCAG 맞춰줘', 'make this accessible', 'keyboard navigation', 'fix focus trap', 'add aria roles'. This skill teaches the METHOD - derive each widget's contract from its interaction pattern and the product's existing primitives; it does not impose a fixed component library or design values."
compatible-tools: [claude, codex]
category: ui
test-prompts:
  - "이 드롭다운 키보드로 조작되게 해줘"
  - "모달 접근성 챙겨줘 (focus trap)"
  - "이 컴포넌트 스크린리더 대응 해줘"
  - "탭 컴포넌트 aria 제대로 넣어줘"
  - "폼 에러를 스크린리더가 읽게 해줘"
  - "make this menu keyboard accessible"
  - "fix the focus management in this dialog"
  - "is this component WCAG compliant?"
---

# The A11y Components

Accessibility is not a layer you sprinkle on at the end. It is the interaction
contract of the component: which keys do what, where focus goes, what the element
announces itself as, and what state it broadcasts. This skill is the *method* for
getting that contract right for any widget - it does not pin you to one component
library or one set of visual values.

## Use this skill when

- Implementing or fixing an interactive component: menu, dialog, combobox/select,
  tabs, accordion, tooltip, popover, listbox, switch, slider, disclosure, etc.
- Keyboard support or screen-reader support is missing, partial, or wrong.
- A WCAG/a11y bar must be met for a component or flow.
- The user says "접근성", "키보드", "a11y", "aria", "focus 관리", "screen reader",
  "WCAG".

## Skip when

- Pure visual styling with no interaction → [the-css-craft](../the-css-craft/SKILL.md)
  (but keep focus-visible and contrast in mind there too).
- Animation/transition behavior → [the-motion-design](../the-motion-design/SKILL.md)
  (reduced-motion is shared ground).

## Prime directive: derive the contract, do not improvise it

Almost every interactive widget is a solved problem with a documented contract.
Do not invent keyboard behavior from intuition.

1. **Identify the pattern.** What is this, really? A menu, a listbox, a dialog, a
   combobox? Name it.
2. **Look up its contract** in the WAI-ARIA Authoring Practices Guide (APG). The
   APG pattern tells you the required roles, states, properties, and - critically
   - the exact keyboard interaction (which arrows, Home/End, Escape, Enter/Space,
   typeahead, focus wrap). Implement that contract.
3. **Prefer the product's existing accessible primitive.** If the repo uses Radix,
   React Aria, Headless UI, or its own headless layer, build on it - those already
   implement the APG contract and handle the hard edges. Hand-rolling ARIA is the
   last resort, not the first move.

The standard decides the behavior; the product decides the look and the primitive.

## The method

### 1. Semantic HTML first, ARIA only to fill gaps

- A real `<button>`, `<a href>`, `<input>`, `<label>`, `<dialog>`, `<details>`
  comes with role, focusability, and keyboard behavior for free. Use them.
- The first rule of ARIA is: don't use ARIA if a native element does the job.
  ARIA changes semantics; it adds no behavior. `role="button"` on a `<div>` still
  needs you to wire Enter/Space, focusability, and disabled handling by hand - and
  you will miss one.
- Never put an interactive control inside another interactive control.

### 2. Keyboard: everything operable, in a sensible order

- Every action available by mouse is available by keyboard. No mouse-only paths.
- Tab order follows visual/reading order. Do not use positive `tabindex`.
- Composite widgets (menus, listboxes, tabs, grids) use **roving tabindex** or
  `aria-activedescendant` so the widget is one tab stop and arrows move within it -
  not one tab stop per item.
- Implement the pattern's specific keys: arrows to move, Home/End to jump,
  Escape to dismiss, Enter/Space to activate, typeahead where the APG specifies it.

### 3. Focus management is the part that gets skipped

- **Visible focus always.** Never `outline: none` without an equally clear
  `:focus-visible` replacement. A keyboard user who cannot see focus is lost.
- **Dialogs/modals**: move focus into the dialog on open, **trap** focus inside
  while open, restore focus to the trigger on close, and close on Escape. A modal
  that leaks focus to the page behind it is broken.
- **Popovers/menus**: focus the first item (or the menu) on open; return focus to
  the trigger on close.
- **Async / route changes**: move focus to the new content or a heading so the
  context change is announced; do not strand focus on a removed element.

### 4. State and announcements

- Reflect state in ARIA: `aria-expanded`, `aria-selected`, `aria-checked`,
  `aria-current`, `aria-disabled`, `aria-pressed` - and keep it in sync with the
  visual state.
- Name every control: visible `<label>`, `aria-label`, or `aria-labelledby`.
  Icon-only buttons need an accessible name. Placeholder text is not a label.
- Use `aria-live` regions for dynamic messages (form errors, toasts, async
  results) so screen readers announce them. Match politeness to urgency
  (`polite` for status, `assertive` for errors that block).
- Group and describe: `aria-describedby` for hints/errors on inputs;
  `role="group"` + label for related controls.

### 5. Forms specifically

- Every input has an associated `<label>` (`for`/`id` or wrapping).
- Errors are programmatically tied to the field (`aria-describedby`) and
  announced; do not signal errors by color alone.
- Required and invalid states use `required` / `aria-required` and
  `aria-invalid`, not just a red border.

### 6. Visual access (still your job)

- **Contrast**: text and meaningful UI must meet the project's contrast target
  (WCAG 2.2 minimums, or APCA where used). See
  [the-design-tokens](../the-design-tokens/SKILL.md) for deriving compliant
  color roles.
- **Target size**: interactive targets meet the minimum touch/click size.
- **Do not encode meaning in color alone** - pair it with text, icon, or shape.
- **Respect `prefers-reduced-motion`** for any animated affordance (see
  [the-motion-design](../the-motion-design/SKILL.md)).

## Verify (don't assume)

- **Keyboard pass**: unplug the mouse mentally - Tab to it, operate it fully, get
  out. Every pattern key works; focus is always visible and never lost.
- **Screen-reader pass**: the element announces its role, name, and state; dynamic
  changes are announced; nothing reads as a bare "clickable group".
- **Automated pass**: run an automated checker (axe, Lighthouse, eslint-plugin-
  jsx-a11y) - it catches missing names, contrast, and role errors, but it does
  **not** prove the keyboard interaction is correct. Both passes are required.

## Anti-patterns

- `<div onClick>` as a button (no focus, no Enter/Space, no disabled).
- `outline: none` with no visible focus replacement.
- A modal that does not trap focus, does not restore it, or ignores Escape.
- One tab stop per item in a menu/listbox instead of roving tabindex.
- Icon-only controls with no accessible name.
- Errors shown only in red, only visually, never announced.
- ARIA roles slapped on to silence a linter while behavior stays broken.
- Positive `tabindex` to "fix" order.

## Done checklist

- [ ] The widget's APG pattern was identified and its contract implemented (or a
      primitive that implements it was used).
- [ ] Native semantic elements used wherever they fit; ARIA only fills real gaps.
- [ ] Fully operable by keyboard, in reading order, with the pattern's keys.
- [ ] Focus is always visible; dialogs trap and restore focus and close on Escape.
- [ ] Composite widgets use roving tabindex / `aria-activedescendant`.
- [ ] Every control has an accessible name; state is reflected in ARIA and stays
      in sync.
- [ ] Dynamic messages (errors, toasts, async) are announced via live regions.
- [ ] Contrast and target-size targets met; meaning never carried by color alone.
- [ ] Verified with both a keyboard pass and a screen-reader/automated pass.

## See also

- [the-design-tokens](../the-design-tokens/SKILL.md) - contrast-compliant color roles
- [the-motion-design](../the-motion-design/SKILL.md) - reduced-motion and feedback
- [the-css-craft](../the-css-craft/SKILL.md) - focus-visible and component CSS
- [the-frontend-director](../the-frontend-director/SKILL.md) - product UI with a11y built in
- [shadcn-ui](../shadcn-ui/SKILL.md) - Radix-based accessible primitives

## Method references

These ground the *reasoning* and the contracts, not visual values:

- WAI-ARIA Authoring Practices Guide - patterns and keyboard contracts: https://www.w3.org/WAI/ARIA/apg/patterns/
- WAI-ARIA spec: https://www.w3.org/TR/wai-aria-1.2/
- WCAG 2.2 Understanding docs: https://www.w3.org/WAI/WCAG22/Understanding/
- Radix Primitives - accessible component implementations: https://www.radix-ui.com/primitives
- React Aria - behavior/accessibility hooks: https://react-spectrum.adobe.com/react-aria/
- MDN ARIA guide: https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA
