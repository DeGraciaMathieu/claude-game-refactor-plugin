# claude-game-refactor-plugin

Claude Code plugin: two commands that turn a single-file HTML/CSS/JS game prototype
into a split, tested and documented codebase.

## Installation

```
/plugin marketplace add DeGraciaMathieu/claude-game-refactor-plugin
/plugin install game-refactor@claude-game-refactor-plugin
```

To work on the plugin itself, clone the repository and add it as a local marketplace
instead: `/plugin marketplace add path/to/claude-game-refactor-plugin`.

## Usage

The prototype must live in a git repository with a clean working tree:

```bash
git init && git add -A && git commit -m "prototype"
```

Then, in Claude Code:

```
/refactor-game index.html    # splits the prototype, tests first
/scaffold-claude             # generates CLAUDE.md, project skills, commands, Stop hook
```

`/refactor-game` stops twice to wait for your approval: after the plan
(archetype, toolchain, extraction order) and after the rules extraction.

## Contents

| Path | Role |
| --- | --- |
| `commands/refactor-game.md` | Orchestrator: 6 steps, 2 validation gates |
| `commands/scaffold-claude.md` | Generates the project's Claude Code ecosystem |
| `skills/game-inventory/` | What to record in a prototype, report format |
| `skills/toolchain-decision/` | Deterministic tree: zero-build by default, Vite on signal |
| `skills/rules-extraction/` | Purity contract, de-randomisation, tranche-by-tranche loop |
| `skills/game-archetypes/` | Four archetypes and their target decomposition |
| `agents/inventory-scanner.md` | Read-only scan, isolated context |
| `agents/refactor-verifier.md` | Accept/block verdict on the handoff contract |
| `templates/` | Files the commands copy into the target project |

The templates are not active: they are models the commands copy into the target
project's `scripts/run-tests.sh`, `docs/decisions.md` and `.claude/settings.json`,
via `${CLAUDE_PLUGIN_ROOT}/templates/`.

## Built with it

Small games that went through this pipeline — all playable:

- [orbite](https://orbite-eight.vercel.app/)
- [warhex](https://warhex.degracia-mathieu.fr/)
- [theater of war](https://theater-of-war.vercel.app/)
- [battle for montélimar](https://battle-for-montelimar.vercel.app/)
- [mémoire 44](https://memoire-44.vercel.app/)
- [jurassic nightmare](https://jurassic-nightmare.vercel.app/)
- [cordon exchange](https://cordon-exchange.vercel.app/)
- [fragline](https://fragline.vercel.app/)
- [dwarf](https://dwarf-ten.vercel.app/)
