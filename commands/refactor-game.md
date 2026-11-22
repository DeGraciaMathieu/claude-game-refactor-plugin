---
description: Split a single-file (or few-file) HTML/CSS/JS game prototype into a layered, tested codebase.
argument-hint: [path to the prototype file, e.g. index.html]
---

# /refactor-game

Target prototype: `$ARGUMENTS` (if empty, look for `index.html` or the single largest
`.html`/`.js` file at the repository root and confirm the choice with the user).

You are restructuring an existing, working game prototype. You are **not** improving it.
Game behaviour at the end must be identical to game behaviour at the start. Any behaviour
change is a bug, including "obvious" fixes — record them in `docs/decisions.md` under
*Deliberately left alone* instead of applying them.

## Golden rule

The domain is **read**, the technique is **decided**.

- Game rules, entities, numbers and terminology already exist in the code. Never invent,
  reinterpret or "clean up" them.
- The file layout, the toolchain and the test strategy do not exist yet. You decide them,
  using the skills below, and you write every decision down in `docs/decisions.md`.

## Preconditions

1. The repository is a git repo with a clean working tree. If it is dirty, stop and ask
   the user to commit or stash first — this refactor relies on `git diff` being readable.
2. If the prototype is already split across more than ~5 source files, stop: this command
   is for prototypes, not for existing codebases. Suggest `/scaffold-claude` instead.

## Sequence

Seven steps, two validation gates. Do not skip a step, do not merge two steps into one commit.

### Step 1 — Inventory (read-only)

Delegate to the `inventory-scanner` agent, passing the prototype path. It returns a
structured report; do not read the whole prototype into the main context yourself.

Read the `game-inventory` skill first if you need to run the scan inline (very small file,
or agent unavailable).

### Step 2 — Plan → **GATE 1**

1. Read the `toolchain-decision` skill and apply its decision tree. State which branch was
   taken and which signal triggered it.
2. Read the `game-archetypes` skill and pick the archetype that matches the inventory.
   State the match, and state explicitly what in this prototype does not fit the archetype.
3. Produce the plan: target tree, module responsibilities, the golden master's scope (which
   functions it calls, which cases it replays — see step 3), the ordered list of rules to
   extract in step 6, and the open questions the code does not settle.

Present the plan and **stop. Wait for the user's approval before touching any file.**

### Step 3 — Golden master

Before anything moves, freeze the prototype's behaviour: replay a fixed set of cases on the
original code, store the outputs, and add a test that replays the same cases on the current
code and compares. Read the `rules-extraction` skill for the procedure.

This is the only check that covers steps 4 and 5, which have no rule tests yet. If the
prototype's logic cannot be reached without the DOM, cover the part that can and record
the rest in `docs/decisions.md` as an open question. Run the suite, commit.

### Step 4 — Extract configuration

Move every magic value found in the inventory into `src/config.js` as named exports:
speeds, grid dimensions, timings, thresholds, colours tied to rules, labels.

Mechanical, no behaviour change. Golden master green, run the game manually, commit.

### Step 5 — De-randomise

Replace every direct `Math.random()` and `Date.now()` / `performance.now()` call inside
rule code with an injected dependency: a seeded RNG passed in, a `dt` parameter passed in.

Read the `rules-extraction` skill for the RNG contract and the injection shape.

This is the step that breaks things most often and it is not optional — no purity, no
tests, no rest of the pipeline. Golden master green, run the game manually, commit.

### Step 6 — Rule-by-rule extraction loop → **GATE 2**

For each rule in the plan's ordered list, one at a time:

1. Move it to `src/rules/` as a pure function (see `rules-extraction` for the contract).
2. Check the moved code for numeric literals other than `0`, `1` and `-1`. Every tunable
   value goes to `src/config.js` in the same tranche.
3. Write its macro test — behaviour, not implementation.
4. Run the suite, golden master included. Green before moving on.
5. Run the game manually and confirm the rule still behaves the same.

Never extract a second rule before the first one's test is green. If an extraction fails
twice, stop, revert that tranche, and revisit the plan with the user.

When the list is done, present the rules layer and its tests and **stop. Wait for the
user's approval** — this is the last cheap moment to change the decomposition.

### Step 7 — Remaining split and output contract

Move the rest into the target tree (`state/`, `render/`, `input/`, `loop/`, `main.js`).
Pure movement, behaviour unchanged, tests stay green. Apply the literal check of step 6 to
every file moved into `loop/`.

Then produce the **handoff contract** — the repository must be readable by archaeology
alone, because `/scaffold-claude` will deduce everything from it:

- `package.json` with real `dev` and `test` scripts.
- A directory tree whose names carry the responsibilities.
- A green test suite, golden master included.
- `docs/decisions.md` filled in from `${CLAUDE_PLUGIN_ROOT}/templates/decisions.md`.
- A `README.md` stating how to run and test — including the fact that opening
  `index.html` by double-click no longer works (native ESM is not served over `file://`).

Finally, run the `refactor-verifier` agent. If it returns `block`, fix what it lists and
run it again.

## Behaviour rules

- Never declare a step done without running the test suite and seeing it pass.
- If an approach fails twice, stop and revisit the plan instead of trying a third variant.
- One commit per step, message stating the step. The user must be able to bisect.
- Ask before adding any runtime dependency. Dev dependencies follow the toolchain
  decision and nothing else.
- Anything the code does not settle goes to `docs/decisions.md` as an open question. Never
  guess to fill a gap.

## Output

Report at the end: steps completed, target tree, rules extracted with their test files,
test suite result, open questions, and the next command to run (`/scaffold-claude`).
