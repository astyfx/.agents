# Verification

## Tests and Checks

- `rg -n --hidden --glob '!**/.git/**' --glob '!tracking/**' --glob '!migration-backups/**' "claude-progress\\.txt|Active Task Path|Last Completed Step|## Next Action|# Progress|## Task$|## Status$" /Users/jacob.kim/.agents`
  - Result: remaining matches are only deliberate legacy-compatibility mentions or historical compatibility notes in live docs/scripts.
- `bash -n /Users/jacob.kim/.agents/scripts/new-task.sh`
  - Result: OK
- `bash -n /Users/jacob.kim/.agents/scripts/init-repo.sh`
  - Result: OK
- `bash -n /Users/jacob.kim/.agents/scripts/init.sh`
  - Result: OK
- `bash -n /Users/jacob.kim/.agents/scripts/check-harness.sh`
  - Result: OK
- `bash -n /Users/jacob.kim/.agents/scripts/hooks/on-stop-handoff.sh`
  - Result: OK
- `bash /Users/jacob.kim/.agents/scripts/check-harness.sh`
  - Result: ALL CHECKS PASSED
