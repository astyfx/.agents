# Skills Index

Maintained alongside `the-skill-creator` (it scaffolds new rows). Update this
file when adding, removing, or renaming a skill, and keep the Category column in
sync with each skill's frontmatter `category`. `scripts/check-harness.sh`
validates that names here match the actual skill set.

| Name | Category | Compatible | Trigger Summary |
|---|---|---|---|
| the-refine-prompt | planning | claude, codex | rough prompts, fuzzy ideas, spec refinement |
| the-skill-creator | workflow | claude, codex | create/update/evaluate skills |
| the-frontend-director | ui | claude, codex | Linear/Sentry-leaning product UI, repo-bound improvements, dashboard/admin, Figma-aware implementation |
| ai-elements | ui | claude, codex | AI chat interface components |
| electron-best-practices | development | claude, codex | Electron + React app architecture, IPC, security, packaging, testing |
| shadcn-ui | ui | claude, codex | shadcn component generation, alias reconciliation, token-safe UI work |
| vercel-react-best-practices | ui | claude, codex | React/Next.js performance optimization |
| the-code-reviewer | review | claude, codex | code review, PR review, bug finding |
| the-theme-token-sync | safety | claude, codex | CSS custom properties, theme presets, built-in theme sync |
| the-terminal-surface-guard | safety | claude, codex | PTY terminal runtime, focus, resize, keep-alive, shell/runtime split |
| the-zustand-guardrail | safety | claude, codex | Zustand selectors, useShallow, rerender fan-out, hot surfaces |
| the-ipc-schema-sync | safety | claude, codex | IPC payload chains, Zod schema sync, provider event parity |
| the-react-effect-guardrail | safety | claude, codex | useEffect/useRef anti-patterns, stale closures, cleanup discipline |
| the-tdd | workflow | claude, codex | test-driven development, TDD cycle |
| the-ralph-prd | workflow | claude, codex | PRD generation and prd.json conversion for Ralph autonomous loop |
| the-ralph-loop | workflow | claude, codex | Ralph loop setup and execution for Claude or Codex, fresh-context autonomous iteration |
| the-api-migrator | workflow | claude, codex | API/dependency upgrade, migration audit and execution |
| the-build-fixer | workflow | claude, codex | build failures, TypeScript errors, CI fixes |
| the-dead-code-detector | workflow | claude, codex | dead code, unused files/exports, stale paths, evidence-based cleanup |
| the-codebase-mapper | workflow | claude, codex | codebase analysis, module map, onboarding guide |
| the-data-analyst | workflow | claude, codex | dataset analysis, visualization, insight reports |
| the-sparkler-to-sbdashboard | ui | claude, codex | Sparkler Storybook design proposals to sbdashboard-ready plans and code |
| the-improvement-loop | workflow | claude, codex | scored iteration, quality improvement loops |
| the-progress-tracker | workflow | claude, codex | resume task, work handoff continuity |
| the-refactoring-planner | workflow | claude, codex | large-scale refactoring, module extraction, product separation |
| the-slack-thread-worker | workflow | claude, codex | Slack thread to task extraction, Jira/resource prep, or end-to-end execution + PR |
| the-pr-reviewer | review | claude, codex | automated PR review, GitHub integration |
| the-design-cloner | ui | claude, codex | faithful clone of Figma/website/library designs with token extraction and side-by-side verification |
| the-css-craft | ui | claude, codex | modern CSS craft, AI-slop prevention, reference fidelity for everyday UI work in sbdashboard/stave/dui |
| the-design-tokens | ui | claude, codex | token-system method: tiers, role-based naming, color/type/space scales, theming; values derived from the product, not hardcoded |
| the-motion-design | ui | claude, codex | motion/micro-interaction method: purpose, easing direction, performance, reduced-motion; durations from the product's motion language |
| the-a11y-components | ui | claude, codex | accessible interactive components: APG keyboard/focus/ARIA contract, semantic-HTML-first, keyboard + screen-reader verification |
| the-provider-router | architecture | claude, codex | Stave Auto / provider routing design reference and change discipline for extensions and redesigns |
| the-agent-cli | cli | claude, codex | design CLIs called by LLM agents — JSON output, exit-code contract, idempotency, NDJSON streaming |
| the-cli-designer | cli | claude, codex | design human-facing CLIs — subcommand taxonomy, help output, error UX, shell completion |
| the-tui-designer | cli | claude, codex | build interactive terminal UIs with Ink — layout, focus, input, non-TTY fallback, signal handling |
| the-agent-tool-schema | cli | claude, codex | one schema drives CLI parser, help, and Anthropic/OpenAI/MCP tool definitions |
| the-subprocess-orchestrator | cli | claude, codex | spawn/kill-tree/timeout/backpressure/PTY discipline for child processes |
| the-cli-packaging | cli | claude, codex | package CLI as signed binary, cross-platform targets, Homebrew/npm distribution, release pipeline |
