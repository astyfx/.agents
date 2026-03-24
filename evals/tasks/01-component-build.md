# Task 01 — Component Build

## Category
Frontend implementation

## Input Prompt

Build a reusable `DataTable` component in React + TypeScript + Tailwind + shadcn/ui.

Requirements:
- Accepts a generic typed `data` array and a `columns` definition array
- Each column definition has: `key`, `header` (string), optional `render` function
- Sortable by any column (click header to toggle asc/desc)
- Client-side text filter: one input above the table that searches across all string fields
- Shows empty state when no results match the filter
- Responsive: horizontally scrollable on small screens
- Accessible: proper ARIA roles, keyboard navigation for sort

Do not use any additional libraries beyond what is already specified. No react-table or similar.

## Success Criteria

- [ ] Component renders with typed props (no `any`)
- [ ] Sort toggles correctly (asc → desc → none)
- [ ] Filter updates the displayed rows in real time
- [ ] Empty state renders when filter matches nothing
- [ ] No TypeScript errors
- [ ] Accessible table structure (thead/tbody, aria-sort)
- [ ] Code follows project conventions (camelCase, named constants, no magic values)

## Scoring Notes

Rework +1 for: type errors, missing empty state, broken sort toggle, non-idiomatic code.
Deduct verification_quality if agent did not check for TS errors or test the sort logic.
