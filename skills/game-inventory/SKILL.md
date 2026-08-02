---
name: game-inventory
description: How to read a single-file HTML/CSS/JS game prototype and produce a structured inventory of its state, loop, rules, rendering, inputs, magic values and in-game documentation. Use this whenever you are about to restructure, split, refactor or document a game prototype held in one or a few files, and whenever /refactor-game reaches its inventory step — even if the file looks small enough to "just read".
---

# Game prototype inventory

Goal: replace "I read the file" with a report someone else could act on. The inventory is
read-only. Do not edit anything while producing it.

## What to look for

| Axis | What to record | Typical signals |
| --- | --- | --- |
| State | Every variable that survives a frame or a turn, its shape, where it is mutated | top-level `let`, a `game`/`state` object, DOM used as storage (`dataset`, class names) |
| Loop | Whether the game is real-time or event-driven, and what drives it | `requestAnimationFrame`, `setInterval`, or only event listeners |
| Rules | Decisions the game makes: legality, collision, scoring, win/lose, propagation, AI | `if` blocks buried inside event handlers and inside the frame callback |
| Rendering | How the screen is produced and how often | `canvas.getContext`, `innerHTML`, class toggles, CSS transitions |
| Inputs | Every listener, and what it does before touching state | `addEventListener`, keyboard maps, pointer handlers |
| Magic values | Every literal that a player would call a rule | speeds, grid size, delays, thresholds, probabilities, scores |
| Randomness & time | Every `Math.random`, `Date.now`, `performance.now`, and whether it feeds a rule | — |
| Living doc | Any in-game rules/help panel, README section or comment block describing behaviour | `<dialog>`, a help overlay, a long header comment |
| Assets | Images, audio, fonts, inline data URIs | — |
| Existing structure | Anything already split out, and whether it is coherent | separate `.js` files, IIFEs, classes |

## Rules for the report

- Cite line numbers or function names for every entry. An inventory without coordinates is
  useless at extraction time.
- Distinguish **rule** from **rendering**. A collision test is a rule; drawing the flash on
  impact is rendering. When a single function does both, say so explicitly — those are the
  expensive tranches.
- Flag every place where state is read straight from the DOM, or where the DOM *is* the
  state. That decides whether a `state/` module is a move or a rewrite.
- Flag every rule that depends on randomness or on wall-clock time. Those must go through
  de-randomisation before they can be extracted.
- Note the language used in comments and in the in-game text. Generated documentation must
  match it.

## Report format

```
## Prototype
<file>, <lines>, <archetype guess>

## State
- <name> — <shape> — mutated in <fn:line>, <fn:line>

## Loop
<driver> — <fn:line> — <what runs each tick, in order>

## Rules  (ordered by extraction cost, cheapest first)
1. <name> — <fn:line> — pure? / DOM-coupled? / random? / time-dependent?

## Rendering
- <target> — <fn:line> — <canvas|DOM|CSS>

## Inputs
- <event> — <fn:line> — <rule touched>

## Magic values
| value | line | meaning |

## Randomness & time
- <call> — <line> — feeds <rule> / cosmetic only

## Living documentation
<file/element> — <what it claims> — <values that look generated>

## Not understood
- <anything you could not attribute with confidence>
```

The *Not understood* section is mandatory and must not be empty out of pride. Anything
listed there becomes an open question in `docs/decisions.md`, never a guess.
