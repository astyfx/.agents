---
name: the-refine-prompt
description: Refine a user's rough, ambiguous, or under-specified prompt into a clearer, more professional instruction for another AI. Use aggressively when the user asks to improve, polish, rewrite, tighten, clarify, structure, professionalize, sharpen, or optimize a prompt, task brief, handoff, request, system prompt, or agent instruction, and also when the user gives a fuzzy idea-dump rather than a clear execution directive. Best for turning rough intent into a prompt with explicit goal, scope, constraints, deliverables, assumptions, and success criteria.
---

# The Refine Prompt Skill

Turn messy intent into prompts that another AI can execute reliably.

## Use This Skill When

- The user has a rough prompt and wants it improved.
- The user wants a prompt to sound more professional, precise, or complete.
- The user wants help turning an idea, task request, or handoff into a prompt for an AI assistant, coding agent, reviewer, writer, or researcher.
- The user asks for a prompt rewrite, prompt cleanup, prompt structure, or prompt optimization.
- The user gives a broad intention, half-formed request, or vague outcome without a strong executable instruction.
- The user seems to want better task framing before actual execution starts.
- The user provides artifacts such as a PRD, issue, spec, planning doc, or Figma handoff and is still defining how the work should be framed.

## Do Not Use This Skill When

- The user is making a direct, concrete execution request with enough actionable context to proceed safely.
- The user is asking for a targeted fix, code change, or debugging step and already provides logs, errors, files, or a clearly bounded task.
- Prompt refinement would only delay obvious execution instead of improving the quality of the work.

## Primary Goal

Produce a refined prompt that is easier for another AI to understand, follow, and execute well without changing the user's real intent.

## Working Approach

1. Infer the likely task type and target AI context from the user's draft.
2. Extract the real objective, inputs, constraints, deliverables, and success criteria.
3. Fix ambiguity, missing structure, contradictions, and vague wording.
4. Ask only the minimum number of questions needed when missing details would materially change the result.
5. If clarification is useful but not blocking, make reasonable assumptions and label them.
6. If the user wants clipboard-first delivery and tool access permits it, copy the final prompt to the system clipboard.
7. Return the refined prompt in clean markdown unless the user prefers clipboard-only confirmation.

## Refinement Rules

- Preserve the user's intent. Improve clarity, not agenda.
- Do not start solving the task unless the user explicitly asks for both refinement and execution.
- Prefer direct, concrete instructions over motivational or decorative language.
- Replace vague words like "good", "better", or "handle this" with observable expectations.
- Add structure only when it improves execution. Do not inflate a simple prompt into a bloated spec.
- Make constraints explicit: scope limits, files, tools, deadlines, style, forbidden actions, and output format.
- When the prompt is incomplete, separate assumptions from confirmed requirements.
- Keep the final prompt in English by default unless the user explicitly asks for another language.
- Default to refinement-first behavior when the user intent is fuzzy and execution would otherwise be premature.
- Treat artifact-driven, planning-oriented, or high-level build requests as refinement-first even if they contain imperative verbs like "make" or "build".
- Treat direct bug-fix, implementation, and debugging requests as execution-first when the scope is already concrete.

## Prompt Content Checklist

Include the parts that actually help for the task. Typical components are:

- role or perspective the AI should take
- task objective
- relevant context and inputs
- constraints and boundaries
- expected deliverables
- quality bar or success criteria
- required output format

## Task-Specific Heuristics

For coding prompts, prioritize repository context, target files, constraints, verification steps, and definition of done.

For writing prompts, prioritize audience, tone, length, source material, must-include points, and forbidden styles.

For research or analysis prompts, prioritize the decision to be made, evaluation criteria, assumptions, sources, and the expected answer shape.

## Output Style

Default to a short structure like this:

1. `Refined Prompt`
2. `Assumptions` if any were needed
3. `Questions` only if key missing details are still blocking

If clipboard copy succeeds and the user did not explicitly ask to see the full prompt in chat, a brief confirmation is acceptable.

## Clipboard Delivery

When the user asks for clipboard-first output and the current environment allows shell commands or clipboard access, copy the final prompt to the system clipboard using the platform-native clipboard command.

- macOS: prefer `pbcopy`
- Linux: prefer `wl-copy`, fallback to `xclip`
- Windows: prefer `clip` or PowerShell clipboard commands

After copying, tell the user the prompt is on the clipboard. If clipboard access is unavailable or blocked, fall back to returning the prompt in chat.

## Sanity-Check Prompts

Use these as lightweight evaluation cases when revising the skill.

1. Input: `Make a cleaner React admin dashboard prompt for another AI`
   Success: the refined prompt asks for product context, layout scope, design direction, constraints, and expected deliverables without over-specifying implementation details.

2. Input: `Help me turn this bug into a prompt for an AI engineer: users get logged out intermittently`
   Success: the refined prompt turns a vague bug report into a debugging brief with reproduction expectations, affected surfaces, logs, hypotheses, verification, and definition of done.

3. Input: `Create a market research prompt for investment review`
   Success: the refined prompt adds target market, timeframe, evaluation criteria, source expectations, output format, and decision-oriented conclusions.

## Avoid

- unnecessary interrogation when the draft is already usable
- generic filler like "be detailed and thoughtful" without specifics
- hidden assumptions presented as facts
- changing the requested scope
- tool- or editor-specific instructions unless the user asked for them

## Done Definition

The final prompt is professional, explicit, easy to paste into another AI, and clear enough that a capable model can understand the job, constraints, and expected output with minimal follow-up.
