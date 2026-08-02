---
name: toolchain-decision
description: Deterministic decision tree for choosing the build and test toolchain of a split game prototype — zero-build with node:test by default, Vite plus Vitest when specific signals are present. Use this before creating package.json, before adding any dev dependency, and whenever /refactor-game reaches its planning step. Never pick a toolchain by feel; run the tree and state the branch taken.
---

# Toolchain decision

Target runtime: **Node 22**. It runs ESM natively and ships a usable built-in test runner,
which is what makes the zero-build branch viable.

## Decision tree

Take the **Vite branch** if *any* of these signals is present:

- the prototype already imports npm packages (pixi, three, howler, matter-js…);
- the prototype is written in TypeScript, or the user wants it to be;
- there are assets that need bundling, hashing or a base-path rewrite for deployment;
- the prototype exceeds ~2000 lines of JavaScript.

Otherwise take the **zero-build branch**. It is the default.

State the branch and the triggering signal in the plan, and repeat it in
`docs/decisions.md`. If a signal is borderline, ask the user instead of deciding alone.

## Zero-build branch

```json
{
  "type": "module",
  "engines": { "node": ">=22" },
  "scripts": {
    "dev": "npx serve .",
    "test": "node --test",
    "test:watch": "node --test --watch"
  }
}
```

- Source is served as native ESM. No bundler, no transpiler, no dev dependency.
- Tests live in `tests/*.test.js` and use `node:test` + `node:assert/strict`.
- Coverage is available behind an experimental flag; do not wire it up. The test strategy
  here is a handful of macro tests, not a percentage.

## Vite branch

```json
{
  "type": "module",
  "engines": { "node": ">=22" },
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "test": "vitest run",
    "test:watch": "vitest"
  }
}
```

- `vite` and `vitest` as dev dependencies, nothing else without asking the user.
- Same test location and the same macro philosophy; only the runner changes.

## Mandatory warning

Both branches break the double-click workflow: native ESM is not loaded over `file://`,
so opening `index.html` directly in the browser stops working the moment the prototype is
split. Say it in the plan, and write it at the top of the generated `README.md` with the
command that replaces it.

## What not to do

- Do not add a linter, a formatter, a CI file or a bundler that the user did not ask for.
  The refactor is already a large enough diff.
- Do not introduce a framework. Splitting a vanilla prototype into modules is the job;
  porting it to React is a different project.
- Do not add a test dependency in the zero-build branch. If you feel you need one, the
  rules are not pure enough yet — fix that instead.
