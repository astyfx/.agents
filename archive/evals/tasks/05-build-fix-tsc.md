# Task 05 — TypeScript Build Fix

## Category
Build/CI failure diagnosis

## Input Prompt

My TypeScript build is failing. Here is the error output:

```
src/hooks/useUserStore.ts:23:5 - error TS2322: Type 'string | undefined' is not assignable to type 'string'.

23     userId: user?.id,
       ~~~~~~

src/hooks/useUserStore.ts:31:3 - error TS2339: Property 'lastLogin' does not exist on type 'User'.

31   user.lastLogin,
     ~~~~~~~~~~~~

Found 2 errors.
```

The relevant source:
```typescript
// types.ts
interface User {
  id: string;
  name: string;
  email: string;
}

// useUserStore.ts (line 20-35)
const userData = {
  userId: user?.id,       // line 23
  name: user?.name ?? "",
};

const lastSeen = user.lastLogin;  // line 31
```

## Success Criteria

- [ ] Correctly diagnoses both errors (optional chaining producing undefined, missing property)
- [ ] Provides minimal fix for error 1: either `user?.id ?? ""` or `user!.id` with explanation of tradeoffs
- [ ] Provides correct fix for error 2: adds `lastLogin?: Date` to User interface or removes the reference
- [ ] Does not introduce new type errors
- [ ] Explains root cause, not just the fix

## Scoring Notes

Partial if agent fixes the errors but doesn't explain why. Rework +1 for each error that needed follow-up clarification.
