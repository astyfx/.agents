---
name: the-frontend-director
description: Build production-grade frontend interfaces for existing-product repos, dashboards, admin panels, settings screens, onboarding flows, product pages, landing-page redesigns, and desktop-style Electron UI with strong product design judgment. Use this skill when the user asks to build, redesign, modernize, polish, or rethink a component, page, flow, or interface where layout, hierarchy, interaction, responsiveness, accessibility, or visual UX materially matter. Prefer existing-repo UI improvement first, dashboard/admin surfaces second, and Figma-backed implementation when designs exist. Default to a minimal, refined product style closer to Linear or Sentry than Jira or AWS, with restrained color and strong readability. Skip this skill for tiny CSS tweaks or logic-only fixes unless the user explicitly wants UI polish, redesign, or a stronger frontend result.
compatible-tools: [claude, codex]
category: ui
test-prompts:
  - "build a dashboard"
  - "컴포넌트 만들어줘"
  - "design this page"
  - "admin panel 만들어줘"
  - "Linear 같은 느낌으로 정리해줘"
  - "Sentry처럼 깔끔하게 다듬어줘"
---

# The Frontend Director

Use this skill for design-sensitive frontend implementation, especially product UI.
It is optimized for app surfaces first, not just marketing pages.

## Default Taste Profile

Unless the user says otherwise, bias toward this taste profile:

- product UI over marketing spectacle
- minimal and refined over loud and expressive
- calm information density over sparse but wasteful layouts
- strong hierarchy and readability over decorative variety
- existing repo improvement and dashboard/admin work over greenfield art direction
- Figma implementation that adapts cleanly into a repo over literal mockup cloning
- Linear/Sentry-style clarity and restraint over Jira/AWS-style clutter
- restrained palette and sober typography over novelty styling

Anti-goals by default:

- dated enterprise UI
- excessive color usage
- typography or layouts that reduce readability
- busy chrome, noisy cards, and scattered visual emphasis

## Trigger Boundary

Use this skill when the task involves:
- new or heavily revised components, pages, dashboards, settings panels, tables, forms, onboarding, admin screens, command surfaces, or desktop-style app shells
- meaningful UI or UX decisions about layout, hierarchy, interaction patterns, information density, navigation, states, responsiveness, accessibility, or polish
- Electron or desktop-web UI built with web technology
- Figma-backed implementation that still needs product-judgment adaptation inside a repo
- repo-bound modernization where the screen should feel more like a sharp product surface than a generic enterprise console

Do not force this skill for:
- tiny spacing, color, copy, or alignment tweaks with no real design judgment
- logic-only fixes behind an existing UI
- mechanical refactors with no visible UX impact

Unless the user explicitly asks for polish, redesign, or a better frontend result.

## Working Order

1. Detect whether the task is in an existing repo or greenfield work.
2. If an existing repo is present, treat it as the default operating mode. Inspect and follow its framework, design system, component patterns, tokens, spacing, motion, and constraints before inventing anything new.
3. If the implementation goal is already clear, ask little or nothing and proceed.
4. If a Figma reference exists, use it as the visual source but still adapt it to the repo's product language, density, and readability bar. Prefer `the-figma-to-code` for extraction when available.
5. If the work is greenfield or under-specified, give a brief direction first:
   - `Direction`: one-sentence visual and product thesis
   - `Key choices`: layout, density, interaction, tone
   - `Questions`: only 2-3 questions that materially change the design
6. Then implement real code, not just suggestions.

For this user's default workflow, prioritize in this order:
- existing repo UI improvement
- dashboard/admin surfaces
- Figma-backed implementation
- greenfield product UI only when the task clearly needs fresh direction

## Default Stack When No Repo Direction Exists

Stay framework-agnostic in conversation, but when you must choose defaults for a new mainstream project, prefer:
- React
- Tailwind CSS
- shadcn/ui
- Electron for desktop shells
- Zustand for client state when needed
- React Hook Form plus Zod for forms and validation
- TanStack Query for server state

Prefer existing or already-installed libraries over introducing alternatives.

## Core Design Stance

Aim for modern, future-facing product UI.
Branch by context:
- `Precision mode`: restrained, sharp, high-clarity, information-dense, confident
- `Expressive mode`: more motion, contrast, lighting, or bolder composition when the product can support it

Do not make every interface loud. Make it intentional.
Future-facing usually means precision, depth, confident motion, and deliberate contrast, not automatic neon sci-fi styling.
For app, dashboard, admin, and desktop surfaces, clarity and workflow come before showmanship.
Default to `Precision mode` unless the user clearly asks for stronger expression.
In practice, precision means: neutral surfaces, disciplined spacing rhythm, one restrained accent family, strong state contrast, and typography that never fights scanning.

## Product UI Heuristics

For app surfaces:
- prioritize hierarchy, scanning speed, workflows, and task completion
- design clear loading, empty, error, success, disabled, and selected states
- use layout structure before adding decorative cards everywhere
- support dense views when the product benefits from it, but keep density orderly
- make dashboard/admin surfaces feel calm and efficient rather than crowded or bureaucratic
- make tables, filters, forms, navigation, and detail panels feel cohesive
- prefer utility copy over marketing copy
- make interactions feel fast and trustworthy
- keep emphasis concentrated so only the most important controls or states pull attention
- let color communicate state and emphasis, not decorate every surface

For desktop-style and Electron interfaces:
- respect windowed app patterns: sidebars, toolbars, inspectors, split panes, dialogs, sheets, resizable regions, and keyboard-first interactions when relevant
- pay attention to focus states, hover states, selected states, drag areas, and reduced-motion behavior
- assume wide-view productivity workflows when context supports them instead of forcing mobile-style stacking
- avoid mobile-first assumptions when the target surface is clearly desktop productivity software

For marketing or showcase pages:
- allow more art direction, narrative rhythm, and stronger visual moments
- still keep hierarchy, copy, and CTA logic disciplined
- avoid turning an app-minded request into a landing-page composition exercise

## Aesthetic Rules

- avoid generic AI aesthetics and interchangeable SaaS templates
- avoid default purple-on-white gradients, generic glassmorphism, and overused safe font stacks unless the repo already uses them
- avoid Jira/AWS-like visual sprawl: too many panels, too many emphasis colors, and too much chrome competing at once
- avoid retro or stale-looking enterprise patterns unless the repo intentionally requires them
- choose typography, spacing, color, and motion as a coherent system
- keep the palette restrained; one accent family is usually enough
- prioritize legible fonts, strong contrast, and stable alignment before adding flair
- avoid novelty type choices or layouts that reduce scan speed
- use CSS variables or theme tokens when appropriate
- prefer a small number of high-impact visual ideas over many weak effects
- match implementation complexity to the intended visual result
- if the repo already has a design language, preserve it instead of fighting it
- in greenfield work, still make the screen feel like a credible product surface rather than a one-off concept shot

## Communication

- keep pre-implementation direction short and concrete
- do not dump long design manifestos when the user asked for implementation
- justify only the choices that materially affect the result

## Quality Bar

The result should be:
- production-grade and functional
- responsive where the surface needs it
- accessible and keyboard-considerate
- consistent with the surrounding product
- polished in edge states, not just the happy path

When appropriate, verify the implemented surface with the project's existing tooling or the most relevant local checks.
