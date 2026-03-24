# Task 08 — Multi-File Refactor

## Category
Refactoring / code quality

## Input Prompt

Refactor the following three files to extract a shared `formatDate` utility and eliminate duplication.

File 1: `src/components/UserCard.tsx`
```tsx
const formatted = new Date(user.createdAt).toLocaleDateString('ko-KR', {
  year: 'numeric', month: 'long', day: 'numeric'
});
```

File 2: `src/components/EventList.tsx`
```tsx
const dateStr = new Date(event.date).toLocaleDateString('ko-KR', {
  year: 'numeric', month: 'long', day: 'numeric'
});
```

File 3: `src/pages/ProfilePage.tsx`
```tsx
const memberSince = new Date(profile.joinedAt).toLocaleDateString('ko-KR', {
  year: 'numeric', month: 'long', day: 'numeric'
});
```

Create the utility at `src/utils/formatDate.ts`, update all three files to use it, and write a vitest test for the utility.

## Success Criteria

- [ ] `formatDate.ts` utility created with correct signature and implementation
- [ ] All three component files updated to use the utility (no remaining inline date formatting)
- [ ] Vitest test file created covering: valid date, invalid date, edge cases
- [ ] No TypeScript errors introduced
- [ ] Each change is minimal (only replaces the date formatting, no unrelated edits)
- [ ] Conventional Commits message if agent commits

## Scoring Notes

Partial if agent creates utility but misses one of the three files. Rework +1 for TS errors.
