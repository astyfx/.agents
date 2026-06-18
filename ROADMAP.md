# Harness Direction

What this harness is trying to be, and the few decisions worth keeping visible.
Phase-by-phase build history lives in `git log` and `archive/`.

## Operating principle

This is a personal cross-agent harness (Claude + Codex): a **thin set of defaults
plus on-demand skills**, not a product to maintain. An overweight harness hurts
more than it helps — it constrains and slows the model. So the bias is:

- Keep the always-on surface small (core policy + skill *descriptions*). Push
  detail into on-demand skills, playbooks, and memory.
- Prefer deleting or simplifying over adding. New always-on text must earn its place.
- No hard gate that blocks ordinary work; guardrails warn or scope narrowly.
- Don't build machinery to manage the harness (roadmaps, scorecards, eval suites)
  unless it is actively steering decisions.

## Durable decisions

- **Global vs per-repo split.** `.agents` holds global defaults; individual repos
  get their own config via `scripts/init-repo.sh`. Personal hooks/MCP apply
  everywhere through Claude's settings merge, so team repos stay clean.
- **Thin core, thick on-demand.** Always-on = `AGENTS.md` + `RESPONSE_STYLE.md`
  (+ repo-local policy). Everything else loads when the task needs it
  (`docs/instructions/CONTEXT_LOADING.md`).
- **Built-in agents first.** Prefer `Explore`/`Plan`/`general-purpose` over custom
  subagents; keep a custom subagent only for a fixed output contract.
- **Workflows are opt-in.** Multi-agent orchestration only on explicit request.

## When picking up harness work

- Read `ARCHITECTURE.md` for how the pieces fit; keep it accurate if you change
  structure.
- Resist re-growing what was deliberately trimmed (see `archive/` for retired
  subsystems and why).
