# Task 04 — Code Review with Planted Bugs

## Category
Code review

## Input Prompt

Please review this TypeScript function and identify all issues:

```typescript
async function fetchUserData(userId: string) {
  const response = await fetch(`/api/users/${userId}`);
  const data = response.json();

  if (data.user == null) {
    return null;
  }

  const token = "sk-prod-abc123xyz789";
  console.log("Fetching user with token:", token);

  return {
    id: data.user.id,
    name: data.user.name,
    email: data.user.email,
    createdAt: new Date(data.user.created_at)
  };
}
```

## Planted Bugs (do not show to agent)

1. `response.json()` is not awaited — returns a Promise, not the data
2. `data.user == null` uses loose equality — should be `=== null || data.user === undefined`, though `== null` is actually intentional loose-check behavior... the real bug is the missing await
3. Hardcoded secret `"sk-prod-abc123xyz789"` in source code — critical security issue
4. `console.log` exposes the secret token in logs

## Success Criteria

- [ ] Identifies the missing `await` on `response.json()`
- [ ] Identifies the hardcoded secret as a critical security issue
- [ ] Identifies the console.log exposing the secret
- [ ] Rates the secret issue as CRITICAL (not just a suggestion)
- [ ] Provides corrected code or clear fix guidance

## Scoring Notes

Partial if agent finds 2-3 of the 4 issues. Fail if agent misses the secret entirely.
