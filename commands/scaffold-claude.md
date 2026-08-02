---
description: Generate the Claude Code ecosystem for an existing project — CLAUDE.md, domain skills, workflow skills, commands and a Stop hook, all deduced from the real code.
argument-hint: [optional: path to the project root, defaults to the repository root]
---

# /scaffold-claude

Generate, inside the target repository, the documentation and tooling Claude Code will
use on it: a root `CLAUDE.md`, domain skills, workflow skills, slash commands and a Stop
hook.

## Golden rule

Copy no specificity from any other project. Stack, conventions, subsystems, terminology —
everything must be deduced from the real code of this repository. If the code does not
settle a point, do not invent it: record it as an open question.

If `docs/decisions.md` exists (written by `/refactor-game`), read it first. It already
holds the arbitrations the code cannot express — reuse them instead of re-deducing them,
and carry its open questions into your own.

## Step 0 — Exploration (before writing anything)

- Detect the stack, the package manager, and the dev / build / test / lint / format
  commands (`package.json`, `Makefile`, CI config, etc.).
- Map the architecture: directories, layers, responsibilities. Identify the separation
  between logic and orchestration **as it exists here** (pure functions vs effects/IO,
  domain vs UI, rules vs rendering).
- Identify the 2 to 5 major domain subsystems that each deserve a dedicated skill. Two
  real subsystems beat five hollow ones — do not pad the list.
- Collect the real conventions: naming, state/data handling, recurring patterns, style,
  domain terminology, language used in comments and documentation.
- Find the existing test setup (framework, command, granularity) and the lint/format setup.
- Find the **living documentation**: any human-readable text describing the project rules
  or behaviour that can drift from the code (an in-game rules or help panel, a README
  section, `docs/…`). Note which of its values are imported or generated dynamically —
  those must be ignored by the doc-sync check.

## Step 1 — Validate the plan

Before generating anything, present: the detected stack and commands, the proposed domain
skills (name + one-line scope), the proposed commands, and the open questions. **Wait for
the user's approval.**

## Step 2 — `CLAUDE.md` (repository root)

1. Title + one-sentence project description.
2. Stack: technologies, versions, commands (dev, test, lint).
3. Code conventions: the non-negotiable rules deduced from the code — layer separation,
   state/data handling, naming, and above all **what must never be done** (the local
   equivalent of "no business logic in the controller"; in a game codebase this is usually
   "no DOM access in `rules/`", "no magic value outside `config.js`").
4. Visual / domain conventions where relevant.
5. Behaviour: process rules. Include "never declare a task finished without running the
   tests and checking they pass" and "if an approach fails twice, revisit the plan before
   continuing".
6. Available skills: the list with a one-line scope each.

## Step 3 — Domain skills (`.claude/skills/<name>/SKILL.md`)

One per retained subsystem. Frontmatter: `name`, `description` (phrased "Use when …"),
`auto_invoke: true`. Content:

- Tables mapping domain concepts to their concrete implementation (which file, which
  function, which field).
- A "Where to put new code" and/or "Adding a new X" section: a numbered, actionable
  procedure pointing at the real files to touch, in order.

Always create, on top of the domain ones:

- **`architecture`** — the project map (module → role → key dependencies) and a table
  "where new code goes, by type of change".
- **`testing`** — the test command, the philosophy (favour macro tests that verify
  functional behaviour, not implementation details), a "test file → covered scope"
  mapping, and "where to put a new test".

## Step 4 — Workflow skills

- **`feature`** (`user_invocable: true`) — understand the request (restate it, invoke
  `architecture`, ask the clarifying questions: numeric values, interactions with what
  already exists, edge cases) → implement within the architecture and `CLAUDE.md` →
  test at macro level and fix until green → update `CLAUDE.md` / the skills / the in-app
  documentation if the scope moved → summarise files changed, tests added, result.
- **`prd`** — explore the existing code to fill in the technical baseline, ask only the
  product decisions, then write a PRD in a fixed format: Goal / Technical baseline /
  Behaviour / Out of scope / Impact per layer / Acceptance criteria / Tests / Risks and
  open questions. Implements nothing: it is a specification document.

## Step 5 — Commands (`.claude/commands/`)

All follow the same skeleton: read `CLAUDE.md` → get the scope via `git diff`,
`git diff --cached`, `git status`, `git log --oneline -5` → stop if there is nothing →
check point by point → run the tests → structured report with a per-item status
(OK / VIOLATION / N/A) and an overall verdict.

- **`review`** — the most complete: conventions + test coverage + maintainability
  (coupling, single responsibility, duplication, function length/complexity, naming, magic
  values) + system coherence (integration with the existing code, shape of state/data,
  respect of the established patterns).
- **`check-conventions`** — lighter, focused on conventions + test/doc coherence + test run.
- **`check-tests`** — analyse coverage, propose the missing macro tests, **wait for the
  user's approval before writing them**, then re-run the suite.

## Step 6 — Stop hooks (`.claude/settings.json`)

Versioned and shared — not `settings.local.json`, which stays reserved for local
permissions. Two guardrails:

**(a) Deterministic — the tests.** A `type: "command"` hook running
`bash "$CLAUDE_PROJECT_DIR/scripts/run-tests.sh"`. Copy the script from
`${CLAUDE_PLUGIN_ROOT}/templates/run-tests.sh` into the target repository and replace the
test command with the real one detected in step 0. Make it executable.

**(b) Semantic — living documentation sync.** A `type: "agent"` hook checking that the
human-readable documentation stays faithful to the code. Write its prompt from the model
in `${CLAUDE_PLUGIN_ROOT}/templates/settings.template.json`, adapted to this project: what is
auto-generated and must be ignored, what text must stay exact, which `git diff HEAD --
<source dirs> <doc file>` to run, and the strict output rule — reply exactly `accept` if
nothing changed or if the doc still reflects the changes, otherwise `block` listing the
stale passages and the expected correction.

Guardrail (b) is optional: add it only if the project actually has textual documentation
that can drift. If it does not, ship the test hook alone.

## Cross-cutting rules

- Invent no technical fact: verify it in the code, or record it as an open question.
- Adapt everything to the real stack — do not mechanically transpose notions from another
  project.
- Every skill and every command must point at real files and functions found in step 0.
- Write the generated documentation in the language already used in the repository's own
  comments and docs. Match it; do not switch.
