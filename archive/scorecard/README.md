# Scorecard

Measured snapshots of harness health over time.

## How snapshots are produced

Snapshots are **generated, not hand-written** — hand-maintained counts drift
instantly (the 2026-04 snapshots were all stale within weeks). Regenerate a
current snapshot with:

```bash
bash scripts/scorecard.sh > memory/scorecard/$(date +%Y-%m-%d)-snapshot.md
```

`*-snapshot.md` files are generated; the older 2026-04 dated files are kept as
historical baselines (point-in-time, not current). Do not hand-edit either —
rerun the script.

## Goals

- track whether prompt-loading changes are actually reducing overhead
- confirm eval history is growing where it informs real decisions
- make repeated failure classes visible
- keep roadmap changes tied to evidence

## Suggested Metrics

- line count of the always-on core docs
- number of real eval result files
- number of eval result files with explicit decision targets
- number of active troubleshooting records
- number of durable decision records
- count of stale legacy notes still waiting for migration
