# Engine Feasibility Spike (T19 input)

## Scope

This is a bounded feasibility spike, not the engine decision. It feeds task T19
of the [implementation plan](./implementation-plan.md) and the open comparison in
[ADR 0015](../../../docs/decisions/0015-adopt-executable-ai-workflow-contracts.md).
It does not select gentle-ai, a local engine, or prompt coordination. The owner
still chooses in T19.

The spike answers four bounded questions: whether gentle-ai v2.9.0 can be
packaged reproducibly in this flake (Q1); whether the deployed Engram 1.7.0
satisfies what gentle-ai v2.9.0 expects (Q2); the minimum interface a
locally-owned engine would expose to both clients (Q3); and the blockers that
must be resolved before the T19 comparison closes (Q4).

Local baseline: `3752d5c43840671467487e9805ef867c2816f5b8`. Frozen upstream:
`Gentleman-Programming/gentle-ai` tag `v2.9.0`, commit
`be49554794917ae92a6dc9dbfa2eb3db5cf70084`. Every claim below is labelled
**proved** (directly observed in source, release metadata, or a command) or
**unverified** (inferred or not exercised). No engine parity or compatibility
beyond the specific observations is claimed.

## Packaging options

Three realistic options exist. None was installed or built in this spike.

### Option A: pinned prebuilt signed archive (fetchurl / fixed-output)

**Verdict: feasible for aarch64-darwin, proved end to end; cross-platform
inferred.**

The release publishes one archive per OS/arch plus a signed `checksums.txt`.
Observed for `gentle-ai_2.9.0_darwin_arm64.tar.gz`:

- HTTP 200, 6,549,599 bytes.
- SHA-256 `0a58d81cd7d76315e1d11ecf6b38abb27ee8e7e709a04c9a786e89636fb559bb`,
  identical to the entry in `checksums.txt` (proved).
- Archive root contains the executable `gentle-ai` (17,178,962 bytes, mode 0755)
  plus `LICENSE`, `README.md`, `docs/`, and `contracts/` (proved by `tar tzvf`).
- `checksums.txt.minisig` exists (HTTP 200, 307 bytes) with trusted comment
  `repo=Gentleman-Programming/gentle-ai;tag=v2.9.0` (proved).

Per-platform hashes from the signed `checksums.txt` (only aarch64-darwin was
downloaded and hash-verified here; the others are read from the manifest and are
unverified against a downloaded file):

| System | Archive | SHA-256 |
| --- | --- | --- |
| aarch64-darwin | `gentle-ai_2.9.0_darwin_arm64.tar.gz` | `0a58d81cd7d76315e1d11ecf6b38abb27ee8e7e709a04c9a786e89636fb559bb` |
| x86_64-darwin | `gentle-ai_2.9.0_darwin_amd64.tar.gz` | `0e1ce0b117e6f15b56e05defecb33a33825c2e25eb8306df09401d41e0a176fb` |
| x86_64-linux | `gentle-ai_2.9.0_linux_amd64.tar.gz` | `7d414cd8cba8ddc0ab9fa4bc309932638c533217b2f999b2a52e7a4fc0bf6f14` |
| aarch64-linux | `gentle-ai_2.9.0_linux_arm64.tar.gz` | `2bdab4684b5d415df9c9423c2022b017c7c1c1d9056f56acc08633fa0d821cfc` |

Caveats:

- `fetchurl` verifies the SHA-256 only. Minisign authenticity is a separate trust
  decision; Nix does not check the signature. The upstream process expects the
  public key to be obtained from a channel independent of the release page
  (`docs/release-signing.md`); no such key payload was provided for this spike.
  A separate check derivation running `minisign -VQm` could enforce it, but that
  key provenance is unresolved.
- A prebuilt binary carries the embedded release trust anchor, so its built-in
  self-updater is enabled. Under an immutable Nix store path an update attempt
  would fail rather than replace the binary; this is presumed safe but
  **unverified**.
- It ships platform-specific binaries rather than building from source.

**UNVERIFIED DRAFT (option A).** Not added to the tree, not evaluated, not built.

```nix
# UNVERIFIED DRAFT - option A: pinned prebuilt release archive.
{ lib, stdenv, fetchurl }:
let
  version = "2.9.0";
  hashes = {
    x86_64-darwin = "0e1ce0b117e6f15b56e05defecb33a33825c2e25eb8306df09401d41e0a176fb";
    aarch64-darwin = "0a58d81cd7d76315e1d11ecf6b38abb27ee8e7e709a04c9a786e89636fb559bb";
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

### Option B: build from source with buildGoModule

**Verdict: feasible-with-caveats; not built, both hashes unknown.**

Upstream facts (proved by reading `.goreleaser.yaml`, `go.mod`, and
`internal/assets/assets.go` at the frozen commit):

- Main package: `./cmd/gentle-ai`; binary name `gentle-ai`.
- `CGO_ENABLED=0`, `-trimpath`.
- Linker flags: `-s -w`, `-X main.version={{.Version}}`, and
  `-X github.com/gentleman-programming/gentle-ai/v2/internal/update/upgrade.releaseMinisignPublicKeys=...`.
- The binary embeds non-Go assets via
  `//go:embed all:claude all:opencode all:generic all:skills all:gga ... all:engram`,
  so the source build needs the full tree, not just `cmd/`.
- `go.mod` declares `go 1.25.10`. nixpkgs `go` is `1.26.7` (proved with
  `nix eval --raw nixpkgs#go.version`), which satisfies the directive.
- The goreleaser `before` hooks generate provider-contract and provenance files
  that are only collected into release archives; they are not needed to compile
  the binary.

Unknowns: the source tarball hash and the `vendorHash`. Upstream has no `vendor/`
directory, so `buildGoModule` must compute `vendorHash` from `go.sum`. The sparse
clone does not contain the whole source tree, so no proof build was attempted.
Leaving `releaseMinisignPublicKeys` unset disables the built-in self-updater
(upstream design: source/test builds retain `UNSET`), which is acceptable when
Nix owns upgrades.

**UNVERIFIED DRAFT (option B).** Not added to the tree, not evaluated, not built.

```nix
# UNVERIFIED DRAFT - option B: build from source.
{ lib, buildGoModule, fetchFromGitHub }:
buildGoModule rec {
  pname = "gentle-ai";
  version = "2.9.0";

  src = fetchFromGitHub {
    owner = "Gentleman-Programming";
    repo = "gentle-ai";
    rev = "be49554794917ae92a6dc9dbfa2eb3db5cf70084";
    hash = lib.fakeHash; # unknown: source tarball hash not computed
  };

  vendorHash = lib.fakeHash; # unknown: no vendor/ dir; compute from go.sum

  subPackages = ["cmd/gentle-ai"];
  env.CGO_ENABLED = 0;

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
  ];

  meta = with lib; {
    description = "Ecosystem, frameworks, and workflows for AI coding agents";
    homepage = "https://github.com/Gentleman-Programming/gentle-ai";
    license = licenses.mit;
    mainProgram = "gentle-ai";
  };
}
```

### Option C: go install path

Upstream documents
`go install github.com/gentleman-programming/gentle-ai/v2/cmd/gentle-ai@vX.Y.Z`
as the Windows fallback, verified against the Go checksum database rather than
minisign (`docs/release-signing.md`). For this flake it is not a distinct
mechanism: it maps onto Option B (`buildGoModule` fetching from the module proxy
with a pinned version). It is not a standalone packaging choice.

## Engram 1.7.0 compatibility

gentle-ai's only direct Engram invocation is a single CLI call. In
`internal/sddstatus/status.go` `exportEngramObservations` runs
`exec.Command("engram", "export", path)` with `cmd.Dir = workspaceRoot` and
decodes:

```json
{ "observations": [ { "title": "...", "content": "...", "project": "...", "scope": "..." } ] }
```

Engram 1.7.0 (`packages/engram/package.nix`, tag `v1.7.0`) provides exactly this
surface:

| Expectation | Engram 1.7.0 | Status |
| --- | --- | --- |
| `engram export <path>` subcommand | `cmd/engram/main.go:108` dispatches `export`; `cmdExport` at `main.go:465` accepts `os.Args[2]` as the output path and writes JSON | proved |
| Top-level `observations` array | `store.ExportData` (internal/store/store.go:144) marshals `observations` alongside `version`, `exported_at`, `sessions`, `prompts` | proved |
| Observation `title`, `content`, `project`, `scope` fields | present on `store.Observation` (store.go:36); `project` is `*string` with `omitempty`, which unmarshals to the empty string in gentle-ai's `string` field | proved |
| `mem_save`, `mem_update`, `mem_search`, `mem_get_observation` | all registered MCP tools (internal/mcp/mcp.go) | proved |
| `mem_save_prompt`, `mem_session_start/end/summary`, `mem_capture_passive`, `mem_stats`, `mem_timeline`, `mem_suggest_topic_key`, `mem_delete` | registered | proved |
| `capture_prompt` parameter on `mem_save` | no occurrence of `capture_prompt` anywhere in the 1.7.0 source | absent |
| `mem_review` lifecycle tool | not registered | absent |
| `mem_merge_projects` / `engram projects consolidate` | not present | absent |
| project auto-detection from git remote | not present in 1.7.0; upstream convention dates it to Engram v1.11.0+ | absent |
| `ENGRAM_DATA_DIR` override | honored at `cmd/engram/main.go:87` | proved |

Interpretation:

- The read path gentle-ai actually executes (`engram export`) is **proved
  compatible** at the field and shape level.
- `capture_prompt`, `mem_review`, and the merge/consolidate repair tools are
  newer optional surfaces. The upstream protocol and convention explicitly
  degrade when they are absent (omit the field / do not fail), so their absence
  is a capability gap, not a hard break. This matches ADR 0015 finding F18.
- Two integration risks are **unverified** and are the ones that could actually
  break status resolution:
  1. **Project name agreement.** gentle-ai matches observations by
     case-insensitive `project` equality and excludes `scope == "personal"`
     (`status.go:1254`). It infers the project from `ENGRAM_PROJECT`, else the
     git config `url =` basename, else the workspace directory name, lowercased
     (`status.go:1119`). Engram 1.7.0 does not infer project itself; whatever the
     writing skill passes is what is stored. Whether the writer's value matches
     gentle-ai's inference has not been exercised.
  2. **Data directory agreement.** The local MCP module sets `ENGRAM_DATA_DIR`
     only for the MCP server process
     (`modules/home/programs/terminal/tools/mcp/default.nix:68`). gentle-ai
     spawns `engram export` as its own subprocess; if that process does not
     inherit the same `ENGRAM_DATA_DIR`, the reader and writer use different
     databases. `ENGRAM_PROJECT` is read by gentle-ai but ignored by 1.7.0, so it
     cannot bridge this by itself.

## Minimum local-engine interface

Derived from the T19 subsystem table and the upstream `gentle-ai.sdd-status/v2`
contract. This is a responsibility list, not a design or an endorsement of
building a local engine.

| Subsystem | Minimum responsibility exposed to both clients |
| --- | --- |
| Change identity and context | Resolve `{project, change}` to one stable key; expose the declared `artifactStore` (`engram`/`openspec`/`hybrid`/`none`) and `workspaceRoot`; select an unambiguous active change. |
| Persistence adapters | Engram: read via `engram export` (or MCP search/get) and write/update the `sdd/{change}/{kind}` topics; OpenSpec: read/write files; `none`: in-memory only. No new database. |
| Workflow state | Per-artifact state (`missing`/`done`/`partial`), task progress (`total`/`completed`/`pending`), dependency readiness (`blocked`/`ready`/`all_done`), and one `nextRecommended` token. |
| Dispatch boundary | One shared phase/worker request and result schema; distinguish terminal results from launch acknowledgements; cancellation and bounded retries. |
| Evidence | Bind verification results to a candidate revision; separate verification from review; detect stale or missing evidence. |
| Completion and archive | Persisted task readback; deterministic delta composition; lossless move with collision handling; terminal-state record. |
| Concurrency and migration | Write ownership, idempotency, partial-write recovery, schema/state upgrades, and rollback. |
| Distribution and tests | Package for both platforms, client-compatibility fixtures, and one named maintenance owner. |

The upstream surface is large. `gentle-ai.sdd-status/v2` alone carries artifact
paths and context files, task progress, dependency states, `actionContext`,
relationships, `remediationState`, optional `reviewOffer`, optional `consent`
envelope, `phaseInstructions`, `blockedReasons`, and `notes`, plus a separate
Git-common-dir attempt chain (`sdd-attempt acquire|settle`) and a verify-result
envelope. A local engine only needs the subset that its two clients actually
consume, but that subset has not been measured. The plan's table is the current
estimate of that effort.

## Blockers and unknowns

1. **Engine choice is open.** This spike produces evidence; it does not decide.
   T19 must still compare options against one acceptance matrix.
2. **Source packaging hashes unknown.** Both the source tarball hash and the
   `buildGoModule` `vendorHash` are unset for Option B. Neither has been
   computed; no build was attempted. Confirming requires a bounded build on
   aarch64-darwin.
3. **Prebuilt trust provenance unresolved.** The minisign public key payload and
   its fingerprint must come from a maintainer-controlled channel independent of
   the release page; none was provided. `fetchurl` alone would not authenticate
   the signature.
4. **Engram project-name agreement unverified.** Whether artifacts written by the
   skills carry the same `project` string that gentle-ai infers is untested.
   Confirming requires an isolated Engram write/read cycle plus
   `gentle-ai sdd-status`.
5. **`ENGRAM_DATA_DIR` propagation untested.** gentle-ai's `engram export`
   subprocess must see the same data directory as the MCP server. Confirming
   requires running the CLI under the deployed environment.
6. **Absent 1.7.0 surfaces.** `capture_prompt`, `mem_review`, and project-merge
   tooling are missing. Whether any upstream gate depends on them (beyond the
   documented graceful degradation) is unverified.
7. **Full source not present.** The sparse clone omits parts of the tree, so the
   complete `embed` set and any other external command dependencies were not
   enumerated beyond `git` (used by `runtime_ledger.go`) and `engram`.
8. **Local-engine effort unmeasured.** The minimum-interface table is inferred
   from the plan and the status contract, not from a prototype. No vertical slice
   was built.
9. **Client handoff not exercised.** No OpenCode or Pi adapter was run against
   either candidate; both remain blocked on T01/T02.

## Verification log

All commands were run from
`/Users/avicente/Developer/aytordev/system` unless noted. Environments: macOS
(darwin), `nix (Nix) 2.35.2`.

Frozen-revision checks:

- `git -C /var/folders/xh/rdhhbdrs6md1_jc5j9fh06yr0000gn/T/opencode/gentle-ai-sdd-audit describe --tags --exact-match`
  -> `v2.9.0` (proved: the clone HEAD is the release tag).
- `git -C ... log -1 --oneline` -> `be49554 Merge pull request #4569 ...`
  (matches the frozen commit).
- GitHub API `commits/v2.9.0` -> `"sha": "be49554794917ae92a6dc9dbfa2eb3db5cf70084"`
  (proved: annotated tag `v2.9.0` resolves to the frozen commit).

Packaging checks:

- `curl -sSL .../v2.9.0/checksums.txt` -> HTTP 200, 625 bytes; printed six
  checksum lines (proved).
- `curl -sSL .../gentle-ai_2.9.0_darwin_arm64.tar.gz` -> HTTP 200, 6,549,599
  bytes.
- `shasum -a 256 gentle-ai_2.9.0_darwin_arm64.tar.gz` ->
  `0a58d81c...559bb`, equal to the signed manifest (proved).
- `tar tzvf gentle-ai_2.9.0_darwin_arm64.tar.gz` -> root `gentle-ai` executable
  (17,178,962 bytes) plus LICENSE, README, docs, contracts (proved).
- `curl -sSL .../checksums.txt.minisig` -> HTTP 200, 307 bytes; trusted comment
  `repo=Gentleman-Programming/gentle-ai;tag=v2.9.0` (proved).
- `nix eval --raw nixpkgs#go.version` -> `1.26.7` (satisfies `go 1.25.10`).
- Read `internal/assets/assets.go` for the `go:embed` set; read
  `.goreleaser.yaml` for `main: ./cmd/gentle-ai`, `CGO_ENABLED=0`, and ldflags.
  No build or `nix eval` of a draft expression was run.

Engram compatibility checks (source read from a fresh clone of
`Gentleman-Programming/engram` at tag `v1.7.0`, commit `d780d86`):

- `grep -n '"export"\|exportCmd' cmd internal` -> dispatch at
  `cmd/engram/main.go:108`; `cmdExport` at line 465 (proved).
- Read `internal/store/store.go:36-52,144-150` for the `Observation` and
  `ExportData` JSON shapes (proved).
- `grep -oE 'shouldRegister\("[a-z_]+"' internal/mcp/mcp.go` -> 14 tools, none is
  `mem_review` (proved absence).
- `grep -rn 'capture_prompt'` -> no matches (proved absence).
- `grep -rn 'ENGRAM_DATA_DIR'` -> present at `cmd/engram/main.go:87`;
  `grep -rn 'ENGRAM_PROJECT'` -> no matches (proved).
- Read `internal/sddstatus/status.go:1090-1131,1239-1256` for the invocation,
  project inference, and match rule (proved).

Baseline state:

- `git rev-parse HEAD` -> `3752d5c43840671467487e9805ef867c2816f5b8`.
- `git status --short` before this file: modified `README.md` and untracked
  `docs/decisions/0015..0017`, `implementation-plan.md`, `proposal.md`
  (pre-existing; not touched by this spike).

Not run, by design: no full flake check, no full-closure build, no
`nix build` of a gentle-ai draft, no live OpenCode/Pi adapter, and no live
Engram write/read cycle. Those are T19/T20 work.
