# Feature: gentle-followups

## Objective

Close the five follow-ups the upstream-alignment cycle left open, on the same
branch and in a single pull request:

| # | Follow-up | Decision |
| --- | --- | --- |
| 1 | `gga` missing from PATH, so `gentle-ai doctor` is unhealthy | **Package it** from source in this flake |
| 2 | The live Pi theme was reset to `dark` | **Restore `aytordev`** |
| 3 | `pi:mcp` warning: built-in MCP disabled, adapter undeclared | **Recommend and apply** (see below) |
| 4 | `R3-001`, an informational suggestion on the overlay check | **Act on it** |
| 5 | Delivery | **One single PR** for the whole branch |

## Authorization

User answered the five open items on 2026-10-18 (original answers in Spanish):
package `gga`; the theme must be `aytordev`; asked for a recommendation on the
MCP warning; do the `R3-001` work; ship everything as **one single PR**.

Not authorized: Engram or Impeccable bumps, model/provider changes, persona
changes, and any merge.

Branch: `feat/upstream-version-alignment`, continuing after `81aac66b`.

## Specs

- **S1 — gga is packaged from source.** `gga` stands for Gentleman Guardian
  Angel (`Gentleman-Programming/gentleman-guardian-angel`), MIT, a **pure Bash**
  project. Upstream publishes **no release assets on any release** (the
  `releases/latest` asset array is empty and no `checksums.txt` exists), so the
  only trustworthy pin is the git tag **`v2.10.1`** plus a `fetchFromGitHub`
  hash. It must not be fetched as a per-platform binary.
- **S2 — gga version comes from the tag, not from `dev`.** Upstream's
  `bin/gga` defaults `VERSION="${GGA_VERSION:-dev}"`, and `VERSION=dev` also
  silences the update probe. The packaged binary must report `gga v2.10.1`.
- **S3 — gga's expected install layout is preserved.** Upstream resolves its
  libraries from `$(dirname $SCRIPT_DIR)/lib/gga` before `…/lib`, so
  `$out/bin/gga` plus `$out/lib/gga/*.sh` needs **no `LIB_DIR` patching**.
- **S4 — gga is a first-class Nix-owned tool.** It gets a Home Manager module
  with exactly the `enable` and `package` options, is enabled by the
  development suite alongside `engram` and `gentle-ai`, and its version is
  pinned by a check so drift is caught.
- **S5 — one writer per PATH entry.** The flake must own `gga`; a Homebrew
  `gga` next to it would make `gentle-ai doctor` warn about shadowing.
- **S6 — the theme is `aytordev`.** The declarative theme file stays the source
  of truth and the live `settings.json` must select it.
- **S7 — `R3-001` is a reliability suggestion on the overlay contract check.**
  Its exact text was not recoverable from the local review artifacts (only its
  id, location `checks/overlay-composition/default.nix:30`, severity
  `SUGGESTION` and disposition `informational` are recorded). The action taken
  is therefore a reconstruction, stated as such: the overlay assertion must pin
  **all three** migrated cargo-bundle keys and the bundle-format restriction,
  not just one key.
- **S8 — a single PR carries the whole branch.** Issue first (the repository
  workflow requires an approved issue and exactly one `type:*` label), then one
  PR for both cycles. No merge.

## Recommendation recorded for the MCP warning

Shell 4 retired `pi-mcp-adapter` in favor of Pi's built-in MCP client, and this
profile still carries the older shape: `extensions: ["-builtin:mcp"]` disables
the built-in client while `pi-mcp-adapter` sits in `node_modules` without being
declared in `settings.json`. The result is that every server in
`~/.pi/agent/mcp.json` is dead, and `gentle-ai doctor` says so. The
recommendation is to remove `-builtin:mcp`, let the built-in client load the
configured servers, and drop the undeclared adapter.

## Tasks

1. [x] Create this feature document and its Engram mirror.
2. [ ] Package `gga` at `v2.10.1` in `packages/gga/package.nix`.
3. [ ] Wire it: Home Manager module, development suite, host homes, the
   module-contract and engine checks, the docs-generation golden, and the docs.
4. [ ] Verify: `nix flake check` and a Darwin system build.
5. [ ] Restore the live theme to `aytordev`.
6. [ ] Apply the MCP recommendation and re-run `gentle-ai doctor`.
7. [ ] Strengthen the overlay assertion for `R3-001`.
8. [ ] Issue, push, and one PR.

## Evidence log

### Task 1 — tracked plan

This document plus the Engram mirror `odd/gentle-followups/tasks`.

### Upstream facts for gga (verified)

| Fact | Value | Evidence |
| --- | --- | --- |
| Repository | `Gentleman-Programming/gentleman-guardian-angel` | upstream README |
| License | MIT | `LICENSE`, 1084 bytes at `v2.10.1` |
| Language | pure Bash (`bin/gga` + `lib/{providers,cache,pr_mode}.sh`) | tag contents |
| Latest release | `v2.10.1`, 2026-07-08T08:06:13Z | GitHub releases API |
| Release assets | **none, on every release** | `releases/latest` asset array empty; gentle-ai issue #108 |
| Version output | `gga v2.10.1` (note the leading `v`) | `bin/gga` `print_version()` |
| gentle-ai's own pin | `GGAVersion = "2.10.1"` | engine `internal/versions/versions.go` at v4.2.0 |
| What `sync` owns | only `~/.config/gga/{config,AGENTS.md}` | engine `internal/components/gga/` |
| Doctor check | PATH lookup of `gga` among core tools | engine `internal/cli/doctor.go` |

Runtime dependencies are provider-dependent (`curl`, `python3`, `gh`, and the
selected provider CLI). They must not be hard-pinned in the derivation.
