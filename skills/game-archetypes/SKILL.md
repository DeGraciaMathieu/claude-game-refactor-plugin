---
name: game-archetypes
description: A catalogue of four game prototype archetypes (real-time canvas, turn-based board, grid simulation, physics playground) with the target module layout, the state shape and the rules worth extracting for each. Use this when planning the decomposition of a game prototype, when deciding what belongs in state versus rules versus render, and at the planning step of /refactor-game — pick an archetype instead of inventing a layout each time.
---

# Game archetypes

Pick the closest archetype, then state explicitly what in this prototype does **not** fit
it. The mismatch is the interesting part of the plan; the match is boilerplate.

Never bend the game to fit an archetype. If nothing matches, say so and design the layout
from the inventory — but say it out loud rather than forcing the closest one.

## 1. Real-time canvas

Continuous loop, entities with positions and velocities, collisions, frame-based rendering.

- Loop: `requestAnimationFrame`, fixed or variable `dt`.
- State: a flat list of entities plus a small world object. Prefer arrays of plain objects
  over classes — pure rules over class instances are painful.
- Rules worth extracting: collision detection, movement integration, spawn conditions,
  damage/score resolution, win/lose conditions.
- Extra modules: `src/rules/physics.js`, `src/rules/collision.js`.
- Watch out for: `dt` accumulating in the rules layer, and rendering reading entity fields
  that only rendering sets. Put those in a separate `view` object.

## 2. Turn-based board

Discrete grid or graph, one action at a time, no continuous loop. Rendering reacts to state
changes rather than to frames.

- Loop: event-driven only. `src/loop/` shrinks to a turn controller: intent → legality →
  apply → render.
- State: the board (grid or map of cells), the pieces, whose turn it is, a phase enum.
- Rules worth extracting: legality of a move, reachable tiles, line of sight, combat
  resolution, turn/phase transitions, victory check.
- Extra modules: `src/rules/legality.js`, `src/rules/turn.js`, `src/state/board.js`.
- Watch out for: the DOM being used as the board. Extracting the board into state first is
  usually the largest and most valuable tranche.

## 3. Grid simulation / propagation

A grid evolving by ticks according to neighbourhood rules: spreading, growth, flow, decay.

- Loop: fixed-step ticks, often slower than the frame rate. Keep the tick separate from the
  render frame.
- State: the grid, plus one derived index per expensive lookup.
- Rules worth extracting: the neighbourhood function, the per-cell transition, the whole
  grid step. The grid step is the single highest-value macro test in this archetype: one
  grid in, one grid out.
- Extra modules: `src/rules/neighbourhood.js`, `src/rules/step.js`.
- Watch out for: in-place mutation of the grid during a step, which silently makes the
  result depend on iteration order. Return a new grid.

## 4. Physics playground

Continuous motion driven by forces, trajectories, inertia, gravity; the game is the
simulation itself.

- Loop: fixed-step integration, rendering interpolating between steps if needed.
- State: bodies with position, velocity, mass; the force sources.
- Rules worth extracting: force computation, integration step, boundary and impact
  response, scoring derived from the trajectory.
- Extra modules: `src/rules/forces.js`, `src/rules/integrate.js`.
- Watch out for: a variable timestep making the simulation irreproducible. Fix the step in
  `config.js` before writing any test, and record the change in `docs/decisions.md` if it
  alters the feel.

## Common core

Whatever the archetype, the layout from `rules-extraction` holds: `config`, `rules`,
`state`, `render`, `input`, `loop`, `main`. Archetypes only add modules inside `rules/`
and decide how thin `loop/` gets.
