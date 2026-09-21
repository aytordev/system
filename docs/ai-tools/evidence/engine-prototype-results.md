# Engine Prototype Results (T19 input)

> **Historical / superseded:** this records the retired local dual-client workflow.
> Current ownership and onboarding: [native adoption guide](../../../modules/common/ai-tools/README.md).
> Past verification and procedures below do not validate or operate the current native Shell.

## Scope

This is a bounded measurement spike for task T19 of the
[implementation plan](../implementation-plan.md), building on
[engine-feasibility.md](./engine-feasibility.md). It exercises the pinned
`gentle-ai` v2.9.0 binary and one Engram-backed scenario; it does **not** select
an engine. It does not compare quality against a local engine or
prompt-coordination baseline, and it does not claim parity, compatibility, or
superiority beyond the specific observations below.

Every claim is labelled **(proved)** (directly observed in this spike) or
**(unverified)** (inferred or not exercised here).

## Environment

- Host: aarch64-darwin (`arm64`), macOS 26.6.2 (build 25G83). **(proved)**
- Nix: `nix (Nix) 2.35.2`. **(proved)**
- Evaluation nixpkgs: `/nix/store/jr0crp0if9q7yxisyzx7nzx53ay7p2bz-source`, forced
  with `{ system = "aarch64-darwin"; }`. **(proved)**
- `gentle-ai` v2.9.0, built from the release archive
  `gentle-ai_2.9.0_darwin_arm64.tar.gz` (SHA-256
  `0a58d81cd7d76315e1d11ecf6b38abb27ee8e7e709a04c9a786e89636fb559bb`, re-verified
  by `shasum -a 256`). Store path
  `/nix/store/mvcd8gn9n4p13wzc05q4fwrw7wlzxpm6-gentle-ai-2.9.0`. **(proved)**
- `engram` v1.7.0 from the ambient profile (`/etc/profiles/.../engram`), with
  `export` and `save` subcommands. **(proved)**
- Repo baseline `HEAD` = `3752d5c43840671467487e9805ef867c2816f5b8`; this spike
  adds no repo file except this document. **(proved)**
- All prototype state lived under
  `/var/folders/xh/rdhhbdrs6md1_jc5j9fh06yr0000gn/T/opencode/t19-prototype/`
  (expression, extracted archive, two disposable git repos, isolated Engram data
  dir). **(proved)**

Note on the hash encoding: the frozen fact is a 64-hex SHA-256. The pinned
nixpkgs rejects a bare hex value in `fetchurl` (`error: hash '...' does not
include a type`), so the same digest was supplied as SRI
(`nix hash convert --hash-algo sha256 --to sri <hex>` ->
`sha256-CljYHNfXYxXh0R7Pazirsn7o5+cJoEyaeG6JY2+1Wbs=`). The bytes hashed are
unchanged. **(proved)**

## Build result

**Verdict: built successfully in isolation. (proved)**

Temporary expression (`/var/.../t19-prototype/gentle-ai.nix`), not in the repo:

```nix
{
  lib,
  stdenv,
  fetchurl,
}: let
  version = "2.9.0";
  hashes = {
    x86_64-darwin = "0e1ce0b117e6f15b56e05defecb33a33825c2e25eb8306df09401d41e0a176fb";
    aarch64-darwin = "sha256-CljYHNfXYxXh0R7Pazirsn7o5+cJoEyaeG6JY2+1Wbs=";
    x86_64-linux = "7d414cd8cba8ddc0ab9fa4bc309932638c533217b2f999b2a52e7a4fc0bf6f14";
    aarch64-linux = "2bdab4684b5d415df9c9423c2022b017c7c1c1d9056f56acc08633fa0d821cfc";
  };
  releaseArch = {
    x86_64-darwin = "darwin_amd64";
    aarch64-darwin = "darwin_arm64";
    x86_64-linux = "linux_amd64";
    aarch64-linux = "linux_arm64";
  };
  system = stdenv.hostPlatform.system;
in
  stdenv.mkDerivation {
    pname = "gentle-ai";
    inherit version;
    src = fetchurl {
      url = "https://github.com/Gentleman-Programming/gentle-ai/releases/download/v${version}/gentle-ai_${version}_${releaseArch.${system}}.tar.gz";
      hash = hashes.${system};
    };
    sourceRoot = ".";
    installPhase = ''
      runHook preInstall
      install -Dm755 gentle-ai $out/bin/gentle-ai
      install -Dm644 LICENSE $out/share/gentle-ai/LICENSE || true
      runHook postInstall
    '';
    meta = with lib; {
      description = "Ecosystem, frameworks, and workflows for AI coding agents";
      homepage = "https://github.com/Gentleman-Programming/gentle-ai";
      license = licenses.mit;
      mainProgram = "gentle-ai";
      platforms = platforms.unix;
    };
  }
```

Exact command (run from the temp dir, output linked only inside it):

```sh
nix build --impure \
  --expr 'let pkgs = import /nix/store/jr0crp0if9q7yxisyzx7nzx53ay7p2bz-source { system = "aarch64-darwin"; }; in pkgs.callPackage /var/folders/xh/rdhhbdrs6md1_jc5j9fh06yr0000gn/T/opencode/t19-prototype/gentle-ai.nix {}' \
  -o /var/folders/xh/rdhhbdrs6md1_jc5j9fh06yr0000gn/T/opencode/t19-prototype/result
```

- Result: exit 0; built `gentle-ai-2.9.0`; no repo file was created. **(proved)**
- The fetched archive was re-downloaded and hashed independently, matching the
  frozen value. **(proved)**
- Only `aarch64-darwin` was built; the other three hashes remain runtime-inferred
  from the prior spike's signed manifest. **(unverified)**
- Minisign authenticity of the archive was **not** checked (no trusted public
  key payload was provided); `fetchurl` verifies the SHA-256 only.
  **(unverified)**

## CLI behavior observed

All outputs below are real, trimmed to the relevant lines. Binary invoked as
`result/bin/gentle-ai`.

- `gentle-ai version` -> `gentle-ai 2.9.0`, exit 0. **(proved)**
- `gentle-ai --help` -> global command list including `install`, `sync`,
  `skill-registry refresh`, `sdd-status`, `sdd-continue`, `sdd-attempt`,
  `sdd-verify-validate`, the `review` family, `update`, `upgrade`, `telemetry`,
  `restore`, `doctor`, `version`, exit 0. **(proved)**
- `gentle-ai skill-registry list` -> exit 0 and printed the discovered user
  skills, e.g.:
  - `branch-pr	user	/Users/avicente/.pi/agent/skills/branch-pr/SKILL.md`
  - `dotfiles-coder	user	/Users/avicente/.pi/agent/skills/dotfiles-coder/SKILL.md`
  - `nix	user	/Users/avicente/.pi/agent/skills/nix/SKILL.md`
  It reads the local Pi skill root, so the listing reflects this machine, not a
  fixture. **(proved)**
- `gentle-ai skill-registry --help` -> `Error: unknown skill-registry command
  "--help" (want refresh or list)`, exit 1. **(proved)**
- `gentle-ai sdd-status --help` -> `Error: unknown sdd-status argument
  "--help"`, exit 1. **(proved)**

## Vertical-slice result

Two disposable git repos were created. One used OpenSpec files; one used an
isolated Engram database with `ENGRAM_DATA_DIR` pointed at a temp directory
(so `~/.engram`, which does not exist, could not be the source). **(proved)**

### OpenSpec store

Repo with `openspec/config.yaml` (`schema: spec-driven`) and a minimal
`openspec/changes/dummy/proposal.md`.

- `gentle-ai sdd-status --json` (no change) returned schema
  `gentle-ai.sdd-status` v2 with `artifactStore: "openspec"`,
  `planningHome.path: <repo>/openspec`, all artifacts `missing`, every
  dependency `blocked`, `nextRecommended: "sdd-new"`, and
  `blockedReasons: ["No active OpenSpec changes found under openspec/changes."]`.
  **(proved)**
- `gentle-ai sdd-status dummy --json` resolved the change:
  `changeRoot: <repo>/openspec/changes/dummy`, `proposal: "done"`,
  `tasks: "missing"`, `nextRecommended: "spec"`, `blockedReasons: []`. **(proved)**
- `gentle-ai sdd-status --json --instructions` (run before the change existed, so
  the change was unresolved) returned the same status plus a `phaseInstructions`
  object for `apply`, `verify`, `archive`, and `remediate`, including concrete
  `sdd-attempt acquire|settle` command templates and, for archive, "Archive only
  when a verify report resolves at that locator". So `--instructions` is
  supported as a flag. **(proved)**
- `gentle-ai sdd-continue dummy` emitted a dispatcher header
  (`next_recommended: spec`), per-phase dependency states, and the next-phase
  instructions. **(proved)**

### Engram store

The store is declared in `openspec/config.yaml` with top-level
`artifact_store: engram` (a bare `schema: spec-driven` yields `openspec`;
`artifact_store: hybrid` yields `hybrid`). **(proved)**

With `openspec/config.yaml` = `artifact_store: engram`, `ENGRAM_DATA_DIR` set to
the isolated dir, and one observation `sdd/dummy/proposal` stored via
`engram save`:

- Without `ENGRAM_PROJECT`, `gentle-ai sdd-status dummy --json` inferred the
  project from the workspace directory name (`ws-engram`), matched it, and
  returned `artifactStore: "engram"`, `changeRoot: "engram:sdd/dummy"`,
  `proposal: "done"`, `blockedReasons: []`. **(proved)**
- `gentle-ai sdd-status --json` with no change argument auto-selected the only
  active change (`changeName: "dummy"`, `nextRecommended: "spec"`). **(proved)**
- With `ENGRAM_PROJECT=wrong-project`, resolution failed cleanly:
  `changeRoot: null`, `proposal: "missing"`,
  `blockedReasons: ["No SDD changes found in the declared Engram artifact
  store."]` — no silent fallback to files or another store. **(proved)**
- A stored project of `WS-ENGRAM` (uppercase) still matched the inferred
  `ws-engram`, confirming case-insensitive matching. **(proved)**
- An observation with `scope: personal` was excluded even though its project
  matched, leaving the change unresolved. **(proved)**

Refusals observed explicitly: `sdd-status --help` (unknown argument) and
`skill-registry --help` (unknown subcommand). The malformed/missing-change case
returned a structured `blockedReasons` entry rather than an error exit.
**(proved)**

## Engram integration findings

The two risks carried over from the prior spike are now partly resolved.

1. **Data-directory agreement — proved for env inheritance, unverified for the
   final client environment.** gentle-ai spawned `engram export` and read the
   observation from the directory named by `ENGRAM_DATA_DIR`; `~/.engram` does
   not exist on this host, so the read could only have come from the inherited
   variable. This proves the child process inherits `ENGRAM_DATA_DIR` from
   gentle-ai's own environment. It does **not** prove that the eventual
   OpenCode/Pi adapter will export `ENGRAM_DATA_DIR` (only the MCP server process
   receives it today, via
   `modules/home/programs/terminal/tools/mcp/default.nix:68`). **(proved for
   inheritance; unverified for the adapter)**
2. **Project-name agreement — proved for the matching rule, unverified for the
   real writer.** With a synthetic writer (`engram save --project`), the stored
   `project` matched gentle-ai's inference (case-insensitively) and mismatches
   were refused rather than silently bridged. The rule gentle-ai applies
   (`ENGRAM_PROJECT`, else git-remote basename, else lowercased workspace dir)
   is consistent with the prior source reading. What remains untested is whether
   the actual SDD writing path (a skill storing `sdd/{change}/{kind}` via
   `mem_save`) stamps the same project string the reader infers; no SDD write
   phase was executed. **(proved for inference/matching; unverified for the real
   writer's value)**
- Engram 1.7.0's `export` shape decoded by gentle-ai without errors. **(proved)**
- `capture_prompt` and `mem_review` remain absent from 1.7.0; this spike did not
  hit any code path that required them. **(unverified for gating behavior)**

## Effect on the T19 comparison

- The pinned prebuilt archive is now **proved buildable and runnable** on
  aarch64-darwin in isolation; packaging is no longer a hypothetical for this
  platform. **(proved)**
- `sdd-status --json` and `sdd-continue` are **proved** to produce the structured
  status and routing envelopes T19 needs, for both an OpenSpec store and an
  Engram store, including a clean refusal on an unresolved change. **(proved)**
- The two Engram integration risks are narrowed: data-dir inheritance and the
  project-matching rule work in a controlled environment; the remaining gap is
  the real adapter/writer, not the binary. **(proved/unverified as above)**
- The comparison still lacks: a local-engine vertical slice, the
  prompt-coordination baseline, any client adapter handoff, an upgrade/migration
  path from Engram 1.7.0, and cross-platform builds. The engine decision stays
  open. **(unverified)**

## Blockers and unknowns

1. **Client handoff not exercised.** No OpenCode or Pi adapter parses
   `sdd-status`/`sdd-continue` output or dispatches phases. The vendored Pi
   `quiet-tools.ts` only recognizes gentle-ai commands for display, and the
   vendored installer pins `INSTALLER_VERSION = "2.7.0"`, not the frozen
   v2.9.0. **(proved)**
2. **Version drift risk in Pi vendor.** The vendored installer would fetch a
   package-local binary at 2.7.0, while this spike (and T24) pin 2.9.0.
   Reconciling or disabling that path is unresolved. **(proved)**
3. **`ENGRAM_DATA_DIR` handoff to gentle-ai is unowned.** Nothing in the current
   modules exports it to a gentle-ai process; only the MCP server gets it.
   **(proved)**
4. **No real writer test.** No SDD skill wrote an artifact to Engram; project
   agreement was shown only with a synthetic writer. **(unverified)**
5. **OpenSpec `artifact_store` values.** `none` did not produce a `none` store in
   `sdd-status` (it fell through to `openspec`); the exact accepted set and its
   semantics are not fully mapped. **(unverified)**
6. **Cross-platform build unproven.** Only aarch64-darwin was realized; the
   x86_64-darwin and Linux hashes were not verified against downloaded files.
   **(unverified)**
7. **Signature trust unresolved.** The minisign public key/provenance from the
   prior spike is still missing; the build verified the SHA-256 only.
   **(unverified)**
8. **No local-engine slice and no baseline.** This spike did not prototype the
   locally owned engine or the prompt-coordination baseline, so no measured
   three-way comparison exists yet. **(unverified)**

## Verification log

All commands were run from
`/Users/avicente/Developer/aytordev/system` unless a different working directory
is shown. `PROTO` =
`/var/folders/xh/rdhhbdrs6md1_jc5j9fh06yr0000gn/T/opencode/t19-prototype`.

Environment and baseline:

- `nix --version` -> `nix (Nix) 2.35.2`.
- `uname -m` -> `arm64`; `sw_vers` -> macOS 26.6.2 (25G83).
- `ls -d /nix/store/jr0crp0if9q7yxisyzx7nzx53ay7p2bz-source` -> exists.
- `command -v engram && engram version` -> `engram 1.7.0`.
- `git rev-parse HEAD` -> `3752d5c43840671467487e9805ef867c2816f5b8`.

Hash encoding:

- `nix hash convert --hash-algo sha256 --to sri 0a58d81cd7d76315e1d11ecf6b38abb27ee8e7e709a04c9a786e89636fb559bb`
  -> `sha256-CljYHNfXYxXh0R7Pazirsn7o5+cJoEyaeG6JY2+1Wbs=`.
- First build attempt with the bare hex hash failed:
  `error: hash '0a58d81c...559bb' does not include a type`.

Build:

- `nix build --impure --expr 'let pkgs = import /nix/store/jr0crp0if9q7yxisyzx7nzx53ay7p2bz-source { system = "aarch64-darwin"; }; in pkgs.callPackage $PROTO/gentle-ai.nix {}' -o $PROTO/result`
  -> exit 0; built `gentle-ai-2.9.0` (`/nix/store/mvcd8gn9n4p13wzc05q4fwrw7wlzxpm6-gentle-ai-2.9.0`).
- (workdir `$PROTO`) `curl -sSL -o gentle-ai.tar.gz https://github.com/Gentleman-Programming/gentle-ai/releases/download/v2.9.0/gentle-ai_2.9.0_darwin_arm64.tar.gz`
  and `shasum -a 256 gentle-ai.tar.gz` -> `0a58d81c...559bb`.

CLI:

- `$PROTO/result/bin/gentle-ai version` -> `gentle-ai 2.9.0`.
- `$PROTO/result/bin/gentle-ai --help`.
- `$PROTO/result/bin/gentle-ai skill-registry list`.
- `$PROTO/result/bin/gentle-ai skill-registry --help` -> exit 1, unknown command.
- `$PROTO/result/bin/gentle-ai sdd-status --help` -> exit 1, unknown argument.

OpenSpec slice (workdir `$PROTO/ws`, a `git init` repo with
`openspec/config.yaml` and `openspec/changes/dummy/proposal.md`):

- `$PROTO/result/bin/gentle-ai sdd-status --json`.
- `$PROTO/result/bin/gentle-ai sdd-status dummy --json`.
- `$PROTO/result/bin/gentle-ai sdd-status --json --instructions` — emitted
  `phaseInstructions`.
- `$PROTO/result/bin/gentle-ai sdd-continue dummy`.

Engram slice (workdir `$PROTO/ws-engram`, isolated data dir
`$PROTO/engram-data`, `openspec/config.yaml` = `artifact_store: engram`):

- `ENGRAM_DATA_DIR=$PROTO/engram-data engram save "sdd/dummy/proposal" "# Proposal for dummy" --project ws-engram --scope project`.
- `ENGRAM_DATA_DIR=$PROTO/engram-data ENGRAM_PROJECT=ws-engram $PROTO/result/bin/gentle-ai sdd-status dummy --json`
  -> `artifactStore: "engram"`, `changeRoot: "engram:sdd/dummy"`,
  `proposal: "done"`.
- Same without `ENGRAM_PROJECT` -> matched via workspace dir name.
- Same with `ENGRAM_PROJECT=wrong-project` -> `changeRoot: null`,
  `blockedReasons: ["No SDD changes found in the declared Engram artifact store."]`.
- `engram save "sdd/casey/proposal" --project WS-ENGRAM` ->
  `sdd-status casey --json` matched (case-insensitive).
- `engram save "sdd/personal1/proposal" --project ws-engram --scope personal`
  -> `sdd-status personal1 --json` unresolved (personal excluded).
- `ls "$HOME/.engram"` -> `No such file or directory` (so the read came from
  `ENGRAM_DATA_DIR`).

Store declaration mapping:

- `openspec/config.yaml` = `artifact_store: engram` -> `"artifactStore": "engram"`.
- `openspec/config.yaml` = `artifact_store: hybrid` -> `"artifactStore": "hybrid"`.
- `openspec/config.yaml` = `schema: spec-driven` -> `"artifactStore": "openspec"`.
- `openspec/config.yaml` = `artifact_store: none` -> `"artifactStore": "openspec"`
  (value not surfaced as a distinct store).

Repo hygiene:

- `git status --short` before writing this file showed only pre-existing
  modifications/untracked docs; this spike added nothing to the repo and used no
  commit. After writing, only this document is new.
