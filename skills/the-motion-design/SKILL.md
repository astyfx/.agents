---
name: the-motion-design
description: "Design motion and micro-interactions (transitions, hover/press feedback, enter/exit, loading, drag, state changes) so UI feels responsive and intentional, not static or over-animated. Use when adding or refining animation. Triggers '애니메이션 넣어줘', '전환 효과', '모션 디자인', 'add transitions', 'animate this'."
compatible-tools: [claude, codex]
category: ui
test-prompts:
  - "이 컴포넌트에 애니메이션 넣어줘"
  - "전환 효과 좀 자연스럽게"
  - "hover/press 인터랙션 살려줘"
  - "모달 열리고 닫히는 모션 만들어줘"
  - "loading 상태 좀 더 매끄럽게"
  - "make this feel smooth and responsive"
  - "add tasteful micro-interactions"
  - "animate this list when items change"
---

# The Motion Design

Good motion is felt, not noticed. It confirms an action, keeps continuity through
a change, and directs attention. Bad motion calls attention to itself, slows the
user down, or animates for decoration. This skill is the *method* for deciding
when and how to move - it does not ship a fixed set of durations or curves. The
product's existing motion language decides those.

## Use this skill when

- Adding or refining transitions, hover/press feedback, enter/exit, loading,
  drag, or state-change animation.
- Deciding how an element should appear, disappear, or respond.
- Making a static UI feel responsive and alive without making it busy.
- The user says "애니메이션", "전환 효과", "인터랙션 살려줘", "hover 효과",
  "smooth", "micro-interactions".

## Skip when

- The product has a motion system and you only need to apply an existing
  transition token → just use it (see [the-design-tokens](../the-design-tokens/SKILL.md)
  for where motion tokens live).
- The task is layout/typography/color with no movement → [the-css-craft](../the-css-craft/SKILL.md).

## Prime directive: motion must have a job

Before animating anything, name the job it does. If you cannot, do not animate it.

Valid jobs:

- **Feedback**: confirm the user's action landed (press, toggle, submit).
- **Continuity**: connect a before/after state so the change is understandable
  (an item moving, a panel expanding, a route transition).
- **Hierarchy / attention**: draw the eye to what changed or what matters now.
- **Spatial orientation**: show where something came from or went (a menu from
  its trigger, a drawer from an edge).

Decoration is not a job. A thing that spins, pulses, or floats for vibe is slop.

## Respect the product's motion language first

Motion is part of a product's character. A calm, precise product (Linear, Sentry)
moves differently from a playful one. Before introducing a curve or duration:

1. Look for existing motion tokens / transition utilities (duration, easing) in
   the theme or component layer. Reuse them.
2. Look at how a representative peer component animates and match its idiom -
   instant vs. eased, subtle vs. expressive, the same easing family.
3. Only define a new duration/easing when the product genuinely lacks one, and
   then add it as a token, not an inline magic number.

Do not paste "300ms ease-in-out" from memory. The numbers below this line are
*principles for choosing*, not values to copy.

## The method

### 1. Easing carries meaning - match the curve to the motion

- Elements **entering** the screen decelerate into place (an ease-out style
  curve): fast first, settling softly. They feel like they arrive.
- Elements **leaving** can accelerate out (an ease-in style curve) - the user has
  moved on, so the exit gets out of the way, often faster than the entrance.
- Movement **between two on-screen states** uses a symmetric/standard curve.
- Avoid linear easing for spatial motion; it reads mechanical. Linear is fine for
  continuous, non-spatial things (a spinner, a progress fill).
- **Springs** (where the stack offers them - Motion/framer-motion) are excellent
  for direct-manipulation and playful continuity; tune by feel (tension/damping),
  not by guessing a duration. Use a spring when the motion should track input;
  use a tweened curve when it should hit a known end state predictably.

Material 3's easing/duration token model and Apple's HIG motion guidance are good
references for *why* enter/exit curves differ - adapt the reasoning, take the
actual values from the product.

### 2. Duration scales with distance and surface size

- Small, local changes (a button press, a checkbox) resolve quickly - long enough
  to perceive, short enough to feel instant.
- Larger movements (a full panel, a sheet crossing the screen) take longer so the
  eye can follow continuity.
- The same gesture should use the same duration everywhere - duration is a token,
  not a per-element decision.
- Err shorter. Animation that makes a user wait is a tax. If it feels slow, it is.

### 3. Performance is a hard contract, not a preference

- Animate **`transform` and `opacity`** only for movement and fades. These are
  compositor-friendly and do not trigger layout.
- Do **not** animate `width`, `height`, `top`, `left`, `margin` for motion - they
  thrash layout and drop frames. Use `transform` (translate/scale) instead;
  reach for FLIP or the View Transitions API when you must animate size/position
  changes structurally.
- Keep animated elements off the main layout path; promote sparingly
  (`will-change`) and only while animating.
- Many simultaneous animations stutter. Stagger or cut.

### 4. Accessibility is mandatory

- Honor `prefers-reduced-motion`: provide a reduced variant (cross-fade or
  instant) for users who request it. Never ship motion with no reduced path.
- Reduced motion means *reduce*, not *remove all feedback* - a press can still
  give an instant state change; just drop the large spatial movement and
  parallax.
- Do not autoplay looping motion that pulls focus near text content.

See [the-a11y-components](../the-a11y-components/SKILL.md) for the broader
interaction-accessibility contract.

### 5. Cover the interaction states that need motion

A complete interactive element usually needs considered transitions for: hover,
press/active, focus-visible, selected, disabled, loading, and enter/exit. Don't
animate the default state and forget the rest. Loading specifically:

- Instant (<~1 frame budget): no loader, just the result.
- Short wait: an inline spinner or disabled+busy state on the control.
- Longer/structural wait: a skeleton that matches the final layout, not a generic
  full-page spinner.

## Anti-patterns (motion slop)

- Animating for decoration with no job (idle float, pulse, gratuitous parallax).
- `scale(0) -> scale(1)` bounce-in on everything; entrance overshoot used as a
  default personality.
- Durations long enough to make the user wait.
- Animating layout properties (`width`/`height`/`top`/`left`/`margin`) for motion.
- The same screen animating ten things at once.
- Pasting a duration/easing from memory instead of the product's tokens.
- No `prefers-reduced-motion` path.
- Easing that contradicts the motion (ease-in on an entrance, linear on a slide).

## Done checklist

- [ ] Every animation has a named job (feedback / continuity / hierarchy / spatial).
- [ ] Durations and easings come from the product's tokens, or new ones were added
      as tokens - nothing pasted from memory.
- [ ] Enter decelerates, exit accelerates, on-screen moves use a standard curve.
- [ ] Only `transform`/`opacity` animate for motion; no layout-thrashing properties.
- [ ] `prefers-reduced-motion` has a real, tested reduced path.
- [ ] Loading affordance matches the wait length (none / spinner / skeleton).
- [ ] Nothing animates just for decoration; removing it would lose meaning, not vibe.
- [ ] Motion matches the product's character (calm vs. expressive).

## See also

- [the-design-tokens](../the-design-tokens/SKILL.md) - where duration/easing tokens live
- [the-a11y-components](../the-a11y-components/SKILL.md) - reduced-motion and interaction a11y
- [the-css-craft](../the-css-craft/SKILL.md) - applying transitions in component CSS
- [the-frontend-director](../the-frontend-director/SKILL.md) - overall product feel
- [the-react-effect-guardrail](../the-react-effect-guardrail/SKILL.md) - when animation is driven by effects/refs in React

## Method references

These ground the *reasoning*, not the values:

- Material 3 motion - easing and duration token model: https://m3.material.io/styles/motion/easing-and-duration/tokens-specs
- Apple HIG - Motion: https://developer.apple.com/design/human-interface-guidelines/motion
- Emil Kowalski - practical UI animation principles: https://emilkowal.ski/ui/7-practical-animation-tips
- Motion (framer-motion) transitions and springs: https://motion.dev/docs/react-transitions
- MDN - animation performance (transform/opacity, compositing): https://developer.mozilla.org/en-US/docs/Web/Performance/Guides/Animation_performance_and_frame_rate
- View Transitions API (structural state changes): https://developer.mozilla.org/en-US/docs/Web/API/View_Transitions_API
