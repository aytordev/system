# Engram Integration Results (T28)

## Scope

This closes the Engram-integration conditions of the adopted engine decision
(ADR 0015, C12) for task T28 of the [implementation plan](./implementation-plan.md),
building on [engine-feasibility.md](evidence/engine-feasibility.md) and
[engine-prototype-results.md](evidence/engine-prototype-results.md). It proves the two
previously unverified risks (data-directory agreement, real-writer project-name
agreement) through the packaged adapter, and records the Engram 1.7.0 gaps
decision.

Frozen inputs: engine `gentle-ai` v2.9.0
(`be49554794917ae92a6dc9dbfa2eb3db5cf70084`), Engram 1.7.0, local baseline
`3752d5c43840671467487e9805ef867c2816f5b8`. The proof is encoded as
`checks/gentle-ai-engine/`, which writes the machine-readable result
`engram-integration-fixture.json` into its output. Every claim below is
**proved** (observed by the check) or **unverified**.

## Adapter boundary and environment ownership (T27)

`packages/gentle-ai/package.nix` exposes `pkgs.aytordev.gentle-ai` from the
pinned upstream release archive (SHA-256 verified; minisign trust anchor
unresolved, so `fetchurl` authenticates the digest only).

`modules/home/programs/terminal/tools/gentle-ai/` is the thin adapter
capability. It installs the engine and the `aytordev-sdd` wrapper, which is the
single call surface. The wrapper owns:

- `ENGRAM_DATA_DIR`, defaulting to the Engram MCP server's directory
  (`${config.xdg.dataHome}/engram`, declared in
  `modules/home/programs/terminal/tools/mcp/default.nix`), overridable by an
  explicit environment value for isolated verification;
- `ENGRAM_PROJECT` when the `engramProject` option is set;
- the workspace root (`AYTORDEV_SDD_ROOT`, default `$PWD`).

Consumed surface: `status`, `continue`, `attempt`, `verify` (validators/archive
composer reused through the engine). Explicitly **not** consumed or wired:
consent/review ledger/`review`, telemetry/`update`/`upgrade`/`restore`, and
model routing (`skill-registry`).

## Data-directory agreement — proved

The check runs the adapter with an isolated data directory and `$HOME` with no
`~/.engram`. An observation written into that directory resolved the change, and
an observation written only into `$HOME/.engram` was **ignored** while
`ENGRAM_DATA_DIR` pointed elsewhere:

| Fixture | Writer target | Adapter read target | `changeRoot` |
| --- | --- | --- | --- |
| Positive | isolated `ENGRAM_DATA_DIR` | same | `engram:sdd/demo` |
| No fallback | `$HOME/.engram` | empty isolated dir | `null` (blocked) |

So the engine's spawned `engram export` reads the adapter-owned database and
never falls back to `~/.engram`. **Proved.**

## Project-name agreement — proved with a required override

The engine infers the project as `ENGRAM_PROJECT`, else the git-remote
basename, else the workspace directory basename (all lowercased), then matches
stored observations case-insensitively. The SDD writer stamps whatever
`project` value the skill passes. These agree when the writer uses the git-remote
basename, but they can disagree when a git remote exists and the writer uses the
directory name:

| Writer `project` | Engine inference | Result |
| --- | --- | --- |
| `engram-agreement` (remote basename) | `engram-agreement` | resolves `engram:sdd/demo` |
| `ws` (directory basename) | `engram-agreement` | unresolved (`null`) |
| `ws`, with `ENGRAM_PROJECT=ws` | override | resolves `engram:sdd/dirname` |

**Decision (single source of truth):** the project name is the git-remote
basename, lowercased (the engine's primary inference); the SDD writer must stamp
that same value. When a repository's remote basename differs from the name the
writer uses, set `aytordev.programs.terminal.tools.gentle-ai.engramProject` to
the writer's value — the adapter exports it for the engine and the check proves
it aligns the disagreement. No silent bridging occurs: a mismatch yields
`blockedReasons: ["No SDD changes found in the declared Engram artifact store."]`
rather than a wrong change. **Proved.**

The writer here is the `engram` CLI with the MCP-equivalent fields the SDD
skills send (`title: sdd/{change}/{type}`, `project`, `scope: project`,
`type: architecture`); the engine reads only those fields. A live model driving
`mem_save` was not exercised. **Unverified** for the model's exact choice of
`project`.

## Engram 1.7.0 gaps and decision

| Gap vs newer Engram | Effect on the adopted engine | Decision |
| --- | --- | --- |
| No observation update path (`import` duplicates) | `mem_update` in the MCP server updates in place; the CLI import path is not used by the engine. | Accept |
| No `capture_prompt` on `mem_save` | Optional upstream field; absent means prompts are not auto-captured. | Accept |
| No `mem_review` lifecycle tool | Optional review surface; ADR 0015 excludes the review ledger from consumption. | Accept |
| No project merge / `consolidate` | Repair tooling only; not on the read/write path. | Accept |
| No git-remote project auto-detection | The engine performs the inference; the writer must stamp the agreed value (override above). | Accept (with override) |

**Decision: accept Engram 1.7.0; do not upgrade.** Reasoning: the only path the
engine actually executes (`engram export` reading `title`/`project`/`scope`)
is proved compatible; the absent surfaces are optional, either non-gating or
explicitly out of the consumed scope; and an upgrade would require its own
schema/migration work (T25) with no demonstrated need for any consumed feature.
Revisit if a required workflow surface (e.g. project merge for repair) becomes
necessary; at that point pin the new version and re-run this check.

## Verification

```sh
nix build .#packages.aarch64-darwin.gentle-ai --no-link
nix build .#checks.aarch64-darwin.integration-gentle-ai-engine \
  --override-input secrets path:./checks/fixtures/secrets
```

Observed: `gentle-ai version` → `gentle-ai 2.9.0`; the check's
`engram-integration-fixture.json` records `projectNameAgreement.resolved =
"engram:sdd/demo"`, `noHomeFallback.resolved = null`, and
`projectOverride.overrideResolved = "engram:sdd/dirname"`. **Proved.**

Remaining unverified: live-model `mem_save` project choice; non-aarch64-darwin
archive hashes (read from the signed manifest, not independently downloaded);
minisign authenticity; and the prebuilt binary's self-updater behavior under an
immutable store path.
