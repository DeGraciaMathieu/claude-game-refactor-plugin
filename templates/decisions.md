# Refactor decisions

Written by `/refactor-game`. Records what the code cannot express: why this layout, why
this toolchain, what was deliberately not touched, what is still undecided.

Read by `/scaffold-claude` so it does not have to re-deduce any of it.

## Archetype

Selected: `<archetype>`
Why: `<what in the inventory matched>`
Does not fit: `<what this prototype does that the archetype does not cover>`

## Toolchain

Branch: `<zero-build | vite>`
Triggering signal: `<the signal from the decision tree>`
Node: 22
Test runner: `<node:test | vitest>`

## Layout

| Module | Responsibility | Came from |
| --- | --- | --- |
| `src/config.js` | | `<original lines>` |
| `src/rules/…` | | |
| `src/state/…` | | |
| `src/render/…` | | |
| `src/input/…` | | |
| `src/loop/…` | | |

## Rules extracted

| Rule | Module | Test | Notes |
| --- | --- | --- | --- |

## Randomness and time

| Call site | Classification | Handling |
| --- | --- | --- |
| | cosmetic / rule-bearing | left in render / seeded rng / dt injected |

Seed: `<fixed | user-provided | from config>`

## Deliberately left alone

Behaviour that looks wrong but was preserved, because the refactor must not change the
game. Each entry: what it is, where, and why it was not fixed.

-

## Open questions

Decisions the code does not settle and that were not made. Never resolved by guessing.

-
