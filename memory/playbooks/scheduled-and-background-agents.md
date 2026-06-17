# Scheduled, Background, and Remote Agents

## Trigger

Use when work is recurring, long-running, detached from the current turn, or
needs isolation: poll a CI run, watch a deploy, run a nightly routine, hand off a
long build, or mutate files in parallel without conflicts.

## Inputs

- what you are waiting for or repeating
- how fast the watched state actually changes (sets the cadence)
- whether the work must survive across turns or sessions
- whether parallel file mutation needs isolation

## Mechanisms (pick the cheapest that fits)

| Mechanism | Use for | Notes |
|---|---|---|
| background `Bash` (`run_in_background`) | a single long command (build, test suite, server) | detached; re-invokes you on exit. No `&` needed. |
| `Agent` with `run_in_background` | a long read/research fan-out off the main turn | notified on completion; continue it with SendMessage. |
| `isolation: 'worktree'` agent | parallel agents that mutate files and would conflict | own git worktree; auto-removed if unchanged. Expensive setup. |
| `isolation: 'remote'` agent | offload to a remote cloud env | always background; availability gated. |
| `ScheduleWakeup` | self-paced `/loop` re-entry; fallback heartbeat | clamp [60,3600]s. |
| `/loop` | run a prompt/command on an interval (or self-paced) | omit interval to let the model pace itself. |
| `/schedule`, `CronCreate` | cron routines / cloud agents on a schedule | recurring, time-of-day or interval. |

## Cadence rule (ScheduleWakeup / loops)

The prompt cache TTL is 5 minutes. Choose the delay against what you are waiting for:

- **60-270s** — actively polling external state the harness cannot notify you
  about (CI run, deploy, remote queue). Cache stays warm.
- **1200-1800s** — idle ticks with no specific signal, or a long fallback
  heartbeat. One cache miss buys a much longer wait.
- **Avoid 300s exactly** — worst of both: you pay the cache miss without
  amortizing it. Drop to 270s or commit to 1200s+.

## Steps

1. Decide if the work is genuinely detached/recurring. If it finishes within the
   turn, just run it inline.
2. Pick the cheapest mechanism from the table.
3. For polling, match the delay to how fast the state changes (cadence rule).
4. For recurring routines, prefer `/schedule` or `CronCreate`; pass the same loop
   prompt back each firing so the next wake repeats the task.
5. Relay only the conclusion when the background work reports back, not the
   transcript.

## Anti-patterns

- **Polling for harness-tracked work.** Background `Bash` and background `Agent`
  re-invoke you automatically on completion, so a short-interval wakeup to "check
  on them" is wasted. Only poll external state the harness cannot track.
- **Round-number minute thinking.** Think in cache windows (270s vs 1200s+), not
  "5 minutes."
- **Worktree isolation by default.** It costs disk + setup per agent; use it only
  when parallel mutation would actually conflict.
- **Detaching trivial work** that would finish faster inline.

## Expected artifacts

- a scheduled routine, background task id, or worktree the main session tracks.

## Verification / rollback

- Confirm the routine fires on the intended schedule and the wake prompt repeats
  the task.
- Stop runaway loops/routines (`TaskStop`, `CronDelete`, `/loop` cancel) before
  editing and resuming.
