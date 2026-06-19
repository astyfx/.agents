# RESPONSE_STYLE.md

Default brevity and clarity rules for agent responses.

Use this file as the single tuning surface for response-style and brevity
adjustments. Brevity is a default to optimize, not a tone gimmick to maximize:
the Boundaries below always win when compression would cost meaning.

## Goals

- Keep responses concise by default.
- Start with the answer.
- Remove filler, hedging, and repetition.
- Preserve technical accuracy and the nuance required to make good decisions.

## Default Rules

- Use short sentences when possible.
- Use flat bullets when they improve scanability.
- Keep normal grammar. This is a brevity policy, not a tone gimmick.
- Follow the language policy from `AGENTS.md` for every user-facing message, including the final answer; this file does not override it.

## Markdown Deliverables (reports and research)

When the final output is a research result, a report, or a document-style
deliverable - or when the user asks for markdown / copy-pasteable / Obsidian
output - format it as a self-contained Markdown document so it drops straight
into a notes vault. This does NOT apply to ordinary replies, quick answers, code
delivery, or debugging; do not wrap those in frontmatter.

Document shape:

- Start with YAML frontmatter, keys in English (portable Obsidian properties):
  `title`, `date` (today, `YYYY-MM-DD`), `tags` (lowercase, no spaces), `type`
  (e.g. research, report, note), and `source` / `sources` (URLs or refs, for
  research). Add other fields only when they carry real value.
- Body in the conversation's language (per the language policy), in clean
  portable Markdown: headings, lists, tables. Avoid Obsidian-only wikilinks
  (the vault is unknown).

Delivery - do both when possible:

- If file tools are available, write the document to `<kebab-title>.md` and tell
  the user the path so they can move it into their vault.
- Also present the full document inside one fenced ```markdown block so it copies
  cleanly with the frontmatter included. If the body itself contains ``` code
  fences, use a 4-backtick outer fence so nothing breaks.
- Where there are no file tools (e.g. ChatGPT web), the fenced block alone is enough.

Keep the body subject to the brevity rules above - structured, not padded.

## Boundaries

- Do not compress high-risk guidance so aggressively that meaning becomes ambiguous.
- For plans, reviews, and tracking artifacts, optimize for clarity and auditability over brevity.
- User instructions override this file.
