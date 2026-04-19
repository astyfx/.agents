---
name: the-ralph-prd
description: "Create or convert a PRD for the Ralph autonomous loop. Step 1: generate a structured PRD from a feature description. Step 2: convert the PRD to prd.json for Ralph execution. Use when the user says 'prd 만들어줘', 'create a prd', 'ralph prd', 'convert this prd to ralph format', 'prd.json 만들어줘', or is starting a new Ralph loop."
compatible-tools: [claude, codex]
category: workflow
test-prompts:
  - "이 기능에 대한 PRD 만들어줘"
  - "create a prd for user notifications"
  - "convert this prd to ralph format"
  - "prd.json 만들어줘"
  - "ralph용 prd 만들어"
---

# The Ralph PRD

Two-step skill: generate a PRD, then convert it to `prd.json` for the Ralph
autonomous loop.

---

## When to Use Each Step

- **Step 1 (PRD generation)**: user has a rough idea and needs a structured
  spec before implementation.
- **Step 2 (prd.json conversion)**: user already has a PRD or spec text and
  needs it in Ralph's execution format.
- Run both steps together when starting a fresh Ralph loop from scratch.

---

## Step 1: Generate a PRD

### Clarifying Questions

Ask 3-5 focused questions with lettered options. Skip questions where the
prompt is already clear. Let users answer with "1A, 2C, 3B" style.

```
1. What is the primary goal of this feature?
   A. [specific goal]
   B. [specific goal]
   C. Other: [please specify]

2. Who is the target user?
   A. New users only
   B. Existing users only
   C. All users

3. What is the scope?
   A. Minimal viable version
   B. Full-featured implementation
   C. Backend/API only
   D. UI only
```

### PRD Structure

Generate a markdown PRD with these sections:

#### 1. Introduction/Overview
What the feature does and what problem it solves.

#### 2. Goals
Specific, measurable objectives as a bullet list.

#### 3. User Stories
Each story must be small enough to implement in one focused session.

Format:
```markdown
### US-001: [Title]
**Description:** As a [user], I want [feature] so that [benefit].

**Acceptance Criteria:**
- [ ] Specific verifiable criterion
- [ ] Another criterion
- [ ] Typecheck/lint passes
- [ ] **[UI only]** Verify in browser using dev-browser skill
```

Acceptance criteria must be verifiable. "Works correctly" is bad.
"Button shows confirmation dialog before deleting" is good.

#### 4. Functional Requirements
Numbered list: `FR-1: The system must...`

#### 5. Non-Goals
What this feature will NOT include.

#### 6. Design Considerations (optional)
UI/UX requirements, mockup links, components to reuse.

#### 7. Technical Considerations (optional)
Constraints, dependencies, integration points, performance requirements.

#### 8. Success Metrics
How success will be measured. Use numbers where possible.

#### 9. Open Questions
Remaining ambiguities.

### Output

Save to `tasks/prd-[feature-name].md` (kebab-case).

---

## Step 2: Convert to prd.json

### Output Format

```json
{
  "project": "[Project Name]",
  "branchName": "ralph/[feature-name-kebab-case]",
  "description": "[Feature description]",
  "userStories": [
    {
      "id": "US-001",
      "title": "[Story title]",
      "description": "As a [user], I want [feature] so that [benefit]",
      "acceptanceCriteria": [
        "Criterion 1",
        "Criterion 2",
        "Typecheck passes"
      ],
      "priority": 1,
      "passes": false,
      "notes": ""
    }
  ]
}
```

Save to `scripts/ralph/prd.json`.

---

## Story Sizing: The Critical Rule

**Each story must be completable in ONE Ralph iteration (one context window).**

### Right-sized stories
- Add a database column and migration
- Add a UI component to an existing page
- Update a server action with new logic
- Add a filter dropdown to a list

### Too big - split these
- "Build the entire dashboard" - split into: schema, queries, UI components, filters
- "Add authentication" - split into: schema, middleware, login UI, session handling
- "Refactor the API" - split into one story per endpoint or pattern

**Rule of thumb:** If you cannot describe the change in 2-3 sentences, it is too big.

---

## Story Ordering: Dependencies First

Stories execute in priority order. Earlier stories must not depend on later ones.

**Correct order:**
1. Schema/database changes (migrations)
2. Server actions / backend logic
3. UI components that use the backend
4. Dashboard/summary views

---

## Acceptance Criteria Rules

Every story must have verifiable criteria:

- Good: "Add `status` column to tasks table with default 'pending'"
- Good: "Filter dropdown has options: All, Active, Completed"
- Good: "Clicking delete shows confirmation dialog"
- Bad: "Works correctly"
- Bad: "Good UX"

**Always include:**
```
"Typecheck passes"
```

**For stories with testable logic:**
```
"Tests pass"
```

**For UI stories:**
```
"Verify in browser using dev-browser skill"
```

---

## Archiving Previous Runs

Before writing a new `prd.json`, check if one exists from a different feature:

1. Read the current `prd.json` if it exists
2. If `branchName` differs from the new feature's branch, and `progress.txt`
   has content beyond the header:
   - Create `archive/YYYY-MM-DD-feature-name/`
   - Copy current `prd.json` and `progress.txt` to archive
   - Reset `progress.txt` with fresh header

`ralph.sh` handles this automatically on startup, but archive manually if
updating `prd.json` between runs.

---

## Checklist Before Saving prd.json

- [ ] Previous run archived if prd.json exists with different branchName
- [ ] Each story is completable in one iteration
- [ ] Stories ordered by dependency (schema to backend to UI)
- [ ] Every story has "Typecheck passes" as final criterion
- [ ] UI stories have "Verify in browser using dev-browser skill"
- [ ] Acceptance criteria are verifiable, not vague
- [ ] No story depends on a later story

---

## Example

**Input:**
```markdown
Add ability to mark tasks with different statuses.
- Toggle between pending/in-progress/done on task list
- Filter list by status
- Persist status in database
```

**Output prd.json:**
```json
{
  "project": "TaskApp",
  "branchName": "ralph/task-status",
  "description": "Task Status Feature - Track task progress with status indicators",
  "userStories": [
    {
      "id": "US-001",
      "title": "Add status field to tasks table",
      "description": "As a developer, I need to store task status in the database.",
      "acceptanceCriteria": [
        "Add status column: 'pending' | 'in_progress' | 'done' (default 'pending')",
        "Generate and run migration successfully",
        "Typecheck passes"
      ],
      "priority": 1,
      "passes": false,
      "notes": ""
    },
    {
      "id": "US-002",
      "title": "Display status badge on task cards",
      "description": "As a user, I want to see task status at a glance.",
      "acceptanceCriteria": [
        "Each task card shows colored status badge",
        "Badge colors: gray=pending, blue=in_progress, green=done",
        "Typecheck passes",
        "Verify in browser using dev-browser skill"
      ],
      "priority": 2,
      "passes": false,
      "notes": ""
    },
    {
      "id": "US-003",
      "title": "Add status toggle to task list rows",
      "description": "As a user, I want to change task status directly from the list.",
      "acceptanceCriteria": [
        "Each row has status dropdown or toggle",
        "Changing status saves immediately",
        "UI updates without page refresh",
        "Typecheck passes",
        "Verify in browser using dev-browser skill"
      ],
      "priority": 3,
      "passes": false,
      "notes": ""
    },
    {
      "id": "US-004",
      "title": "Filter tasks by status",
      "description": "As a user, I want to filter the list to see only certain statuses.",
      "acceptanceCriteria": [
        "Filter dropdown: All | Pending | In Progress | Done",
        "Filter persists in URL params",
        "Typecheck passes",
        "Verify in browser using dev-browser skill"
      ],
      "priority": 4,
      "passes": false,
      "notes": ""
    }
  ]
}
```
