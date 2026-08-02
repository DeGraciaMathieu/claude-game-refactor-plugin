---
name: rules-extraction
description: The purity contract, the de-randomisation procedure and the tranche-by-tranche loop for pulling game rules out of DOM handlers into a pure, testable rules layer. Use this whenever you extract, move or test game logic, whenever you touch Math.random or Date.now in a prototype, and at every tranche of /refactor-game step 4 and 5 — this is the step that decides whether the whole refactor is testable.
---

# Rules extraction

The rules layer is the point of the refactor. Everything else is moving files around.

## Purity contract

A module under `src/rules/` must satisfy all of these:

1. No `document`, `window`, `canvas`, no DOM node in or out.
2. No `Math.random()`, no `Date.now()`, no `performance.now()`.
3. No mutation of its arguments. Take state, return the next state or a decision.
4. No import from `render/`, `input/` or `loop/`. It may import `config.js` only.
5. Same inputs, same outputs, every time, in any order.

If a function cannot satisfy 1–5, it is not a rule: it is orchestration, and it belongs in
`loop/` or `input/`. Say so instead of forcing it.

## De-randomisation (before any extraction)

Randomness and time are the two hidden inputs that make rules untestable. Turn them into
explicit parameters.

**Random.** Introduce one seeded generator, injected wherever a rule needs it:

```js
// src/rules/rng.js
export function createRng(seed) {
  let s = seed >>> 0;
  return function next() {
    s = (s * 1664525 + 1013904223) >>> 0;
    return s / 4294967296;
  };
}
```

The rule receives `rng` as an argument; only `main.js` decides the seed. A test passes a
fixed seed and gets a deterministic result.

**Time.** A rule never reads the clock. The loop measures elapsed time and passes `dt` in.
A turn-based game usually needs no time at all — check before adding it.

**Cosmetic exception.** Randomness that only feeds rendering (particle jitter, screen
shake, sprite variation) stays in `render/` and does not need a seed. Decide per call site,
and record the calls you classified as cosmetic in `docs/decisions.md`.

## The tranche loop

One rule at a time. A tranche is finished only when its test is green **and** the game has
been run by hand.

1. **Pick** the next rule from the plan's ordered list. Cheapest first: the ones already
   almost pure.
2. **Move** it to `src/rules/<name>.js` as a pure function. Do not rewrite it — cut, paste,
   turn implicit inputs into parameters, and nothing else. Resist renaming variables in the
   same tranche; that is a separate, later commit if you want it.
3. **Call it** from where it used to live. The call site keeps the side effects.
4. **Test it** — one macro test, see below.
5. **Run** `npm test`. Green before continuing.
6. **Play** the game and confirm the rule behaves as before.
7. **Commit**, one tranche per commit, message naming the rule.

Never start tranche N+1 with tranche N red. If a tranche fails twice, revert it and take
the question back to the user — the decomposition is probably wrong, not the code.

## Macro tests, not unit tests

Test what a player would notice, in the domain's own vocabulary.

- Good: "a unit cannot move onto an occupied tile", "the fire spreads to adjacent flammable
  tiles at the configured rate", "the score increases when the flag is captured".
- Bad: "`computeNextIndex` returns 4", "the internal array has length 3 after `push`".

Shape:

```js
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { canMove } from '../src/rules/movement.js';

test('a unit cannot move onto an occupied tile', () => {
  const state = { units: [{ id: 'a', x: 1, y: 1 }, { id: 'b', x: 1, y: 2 }] };
  assert.equal(canMove(state, 'a', { x: 1, y: 2 }), false);
});
```

Build state with a small explicit literal, not with a helper that hides the setup. The test
must read as a rule statement — if you have to explain it to read it, it is testing
implementation.

Aim for one or two tests per rule, covering the nominal case and the one edge case that
made the rule exist. Coverage percentage is not a target here.

## Where things end up

| Layer | Contains | May import |
| --- | --- | --- |
| `src/config.js` | every named constant | nothing |
| `src/rules/` | pure decisions and transitions | `config` |
| `src/state/` | the state shape, its factory, its accessors | `config` |
| `src/render/` | everything that writes to the screen | `config`, `state` (read-only) |
| `src/input/` | listeners, mapping events to intents | `config` |
| `src/loop/` | orchestration: intent → rule → state → render | all of the above |
| `src/main.js` | wiring, seed, entry point | all of the above |

The arrow only ever points down this table. A rule importing a renderer is the failure mode
to watch for; check it at the end of every tranche.
