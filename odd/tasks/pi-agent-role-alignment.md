# Feature: pi-agent-role-alignment

Align the repository's agent-model profiles with the agent vocabulary gentle-pi
actually ships: route the ten package-owned agents and the two provider review
roles, and stop routing the thirteen `sdd-*` roles retired upstream.

## Specs

- **S1 — Authorization.** User selected `Repo + runtime`: the change covers the
  three profile files, the engine check, the Pi README, and a one-time cleanup
  of `~/.pi/gentle-ai/models.json` and `~/.pi/agent/subagents.json`. Push, PR and
  merge stay the user's decision.
- **S2 — Per-profile delegation routing.** User's exact words:
  "Pues en opensource los opensource, en subscripcion los subscripcion y en el hybrid, el que corresponda."
  Materialised as: `opensource` keeps `nan/*`; `openai-subscription-complex` uses
  `openai-codex/gpt-6.1-sol` for all three; `hybrid-nan-openai` keeps
  `gentle-ai-explore` and `gentle-ai-worker` on `nan/*` and puts `gentle-ai-verify`
  on `openai-codex/gpt-6.1-sol`, mirroring that profile's `sdd-explore` /
  `sdd-apply` / `sdd-verify` split (independent verification on a different
  model family than the writer).
- **S3 — Vocabulary invariant.** Every declared role in every profile is either a
  package-owned agent shipped by gentle-pi 4.1.0 (`gentle-ai-explore`,
  `gentle-ai-verify`, `gentle-ai-worker`, `jd-fix-agent`, `jd-judge-a`,
  `jd-judge-b`, `review-readability`, `review-reliability`, `review-resilience`,
  `review-risk`), one of the two provider review roles
  (`review-refuter`, `review-validator`), or `orchestrator`; and no package-owned
  agent is missing. The invariant is asserted by the repository check, so a
  future drift fails `nix flake check`.
- **S4 — Provider review roles stay.** `review-refuter` and `review-validator`
  remain in the profiles (they reach `models.json`, never `subagents.json`):
  the review relay reads them there. They are not agents and must not be
  removed by the cleanup.
- **S5 — Evidence.** The vocabulary assertion fails before the profile change and
  passes after it, and every non-`sdd-*` role keeps the model and thinking level
  it has today.

## Tasks

- [x] **PAR-1** RED. Add the vocabulary assertion to
  `checks/gentle-ai-engine/default.nix` while the profiles still declare the
  thirteen `sdd-*` roles; observe the check fail naming the new assertion.
- [x] **PAR-2** Align. Remove the thirteen `sdd-*` roles from
  `profiles/opensource.json`, `profiles/openai-subscription.json` and
  `profiles/hybrid-nan-openai.json`; add `gentle-ai-explore`,
  `gentle-ai-verify` and `gentle-ai-worker` per S2; update
  `expectedHybridProfile`; observe GREEN.
- [x] **PAR-3** Docs. State the role vocabulary in
  `modules/home/programs/terminal/tools/pi/README.md` and record the superseded
  constraint in `odd/tasks/pi-agent-model-profiles.md`.
- [ ] **PAR-4** Runtime cleanup. Remove the thirteen `sdd-*` keys from
  `~/.pi/gentle-ai/models.json` and `~/.pi/agent/subagents.json` after a verified
  backup; the merge is additive, so the profile change alone does not remove
  them. **Half done**: `subagents.json` is cleaned; `models.json` is blocked by
  the native guard and needs the operator (see "Runtime cleanup" below).
- [x] **PAR-5** Verify. Engine check GREEN, `just fmt-check`, and a broader
  all-systems evaluation.
- [ ] **PAR-6** Commit the work unit(s) on a feature branch. Waiting on the
  user's decision.

## Runtime cleanup

`~/.pi/agent/subagents.json` (mode 0600, backup at `/tmp/par-subagents-backup.json`):
25 `model_profiles` → **11**, zero `sdd-*`, before sha256
`dc5c5928d0d6c6f1c707aead62529115eaf1a8cc93730883c6cf08a6f649e8ed`, after
`a41e5345ea3c2e60c150b579bc090e5256f548d33e8b3c7a90bd4ae3e2627334`. The eleven
survivors are the three delegation agents, the three Judgment Day agents, the
four 4R reviewers and the user-owned `civislend-astra-structural-auditor`.

`~/.pi/gentle-ai/models.json` was **not** touched. The native guard
(`lib/auto-permission-runtime.ts:173-184` in gentle-pi 4.1.0) blocks `write` and
`edit` inside that config home and any shell command containing its path, so a
model tool must not change it. Until it is cleaned it keeps 25 keys (13 `sdd-*`,
inert: no consumer reads them). Operator recipe, preserving mode and inode:

```sh
f=~/.pi/gentle-ai/models.json
cp -p "$f" /tmp/models.json.bak
jq 'with_entries(select(.key | startswith("sdd-") | not))' /tmp/models.json.bak > /tmp/models.json.new
jq -e 'length == 12' /tmp/models.json.new && cat /tmp/models.json.new > "$f"
```

The store `~/.pi/gentle-ai/profiles.json` needs no manual step: the activation
merge overwrites declared profile names, so the next `darwin-switch` replaces
the `sdd-*`-bearing `opensource`/hybrid/subscription entries with the aligned
ones.

## Verification evidence

Parent-run, 2026-10-16, on this host:

- **RED** (`PAR-1`), runner
  `nix build .#checks.aarch64-darwin.integration-gentle-ai-engine
  --override-input secrets path:./checks/fixtures/secrets
  --no-write-lock-file --no-link`:
  `error: AI ownership failures: agentRoleCoverage, agentRoleVocabulary`,
  exit 1.
- **GREEN** (`PAR-2`), same runner: exit 0.
- `just fmt-check`: exit 0, "formatted 408 files (0 changed)".
- `nix flake check --no-build --override-input secrets
  path:./checks/fixtures/secrets --no-write-lock-file`: exit 0, "all checks
  passed!" (Darwin; warns that x86_64-linux is omitted as incompatible on this
  host). With `--all-systems`: exit 0, "all checks passed!", no omitted-systems
  warning.
- **Repository-wide readback**: no `sdd-` reference remains in any `.nix`,
  `.json`, `.sh` beyond this document and the check's comment; the remaining
  hits are ADRs under `docs/decisions/` describing the retired SDD era, plus
  this feature document.

Independent verifier (`gentle-ai-verify`, read-only, separate session):
verdict **PASS** on S1, S2, S4 and S5, and S3 functionally, with one advisory
finding.

- S1: only the six modified files plus the new untracked document; `main`, no
  commit, no branch, no push; `~/.pi/gentle-ai/**` untouched.
- S2: the three maps derived with `jq` match S2 exactly.
- S3: all three profiles have exactly 13 roles; bidirectional enforcement proven
  by scratch perturbation (a dropped agent and an invented role each failed).
- S4: `review-refuter`/`review-validator` stay out of `model_profiles` in the
  rendered documents while remaining in `models.json`.
- S5: preservation proven against `git show HEAD:<profile>` — every surviving
  role keeps its model and thinking, only the thirteen `sdd-*` ids are removed
  and only the trio is added; the check output was served from the store, and
  the verifier proved the eval-time gate is what moved by showing the same
  attribute fails to evaluate with the `HEAD` profiles.
- **Finding (advisory, fixed)**: `lib.subtractLists a b` is `b \ a`, so both new
  checks had their arguments inverted relative to their names and comments. The
  union still enforced S3, so no spec behavior failed, but the labels lied.
  Fixed by swapping the arguments; orientation re-proved against the real
  nixpkgs lib (`lib.subtractLists profileRoles declared` isolates an unknown
  role, `lib.subtractLists declared profileRoles` isolates a missing one). Two
  further assertions were added from the verifier's probe set:
  `defaultProfileAllNan` (S2, the default profile's all-nan character) and
  `defaultProviderRolesExcludedFromSubagents` (S4, the same exclusion for the
  default profile).
- **Re-check after the fix**: engine check exit 0; `just fmt-check` exit 0
  (408 files, 0 changed).

Honest limits: the check's `runCommand` phase was not re-executed locally (the
output was substituted from the store, and its derivation is content-independent
of the profiles), so the moved gate is the evaluation-time assertion, not the
shell body. `just darwin-switch` was **not** run: the runtime half of the change
is not live on this machine yet.


## Progress

Two work-unit commits on `main`, pushed 2026-10-16 over the range
`d916e7ab..5159f29f` (`git push origin main`, exit 0, local and `origin/main` in
0/0 afterwards):

- `eec64e8e` `fix(pi): align agent-model profiles with the shipped role
  vocabulary` — 6 files, +122/−169: the three profiles,
  `checks/gentle-ai-engine/default.nix`, the Pi README and the reconciliation
  in `odd/tasks/pi-agent-model-profiles.md`.
- `5159f29f` `docs(odd): track the pi-agent-role-alignment feature document` —
  1 file, +173: this document.

Both passed the repository pre-commit hooks (conflict markers, deadnix, statix,
treefmt, typos) and carry an SSH signature. The user chose a direct push to
`main` over a feature branch and pull request, so the branch/PR conventions this
repository normally uses were explicitly overridden for this change; this
evidence note is committed separately, after that push.

## Log

- **L1 (user, verbatim):** "por que los agentes gentle-ai-* siguen disponibles?"
- **L2 (user, verbatim):** "Entonces los que sobran son los sdd?"
- **L3 (user, verbatim):** "Pero no deberíamos estar alineados con los agentes
  que ofrece gentle-pi?"
- **L4 (user choice):** scope `Repo + runtime`.
- **L5 (user, verbatim routing answer):** "Pues en opensource los opensource, en
  subscripcion los subscripcion y en el hybrid, el que corresponda." (adopted as
  S2)
- **L6 (evidence, 2026-10-16):** gentle-pi 4.1.0 `assets/agents/` ships ten agent
  definitions; `~/.pi/agent/agents/` holds those ten plus the user-owned
  `civislend-astra-structural-auditor.md` and zero `sdd-*` (retired by
  `lib/agent-assets.ts` `RETIRED_MANAGED_ASSETS`). The three profiles still
  declare thirteen `sdd-*` ids, and the runtime files carry them:
  `~/.pi/agent/subagents.json` has 24 profiles (13 `sdd-*`) and
  `~/.pi/gentle-ai/models.json` has 25 keys (13 `sdd-*`).
- **L7 (evidence):** the delegation trio is absent from every profile and present
  in the runtime files only through the additive merge
  (`modules/home/programs/terminal/tools/pi/agent-profiles.nix:263-267`).
- **L8 (consequence):** `odd/tasks/pi-agent-model-profiles.md` justified keeping
  roles without shipped agents because only three ids lacked a definition
  (`sdd-sync` retired, the two provider roles). Upstream retired the whole SDD
  family in the 4.1 cycle, so that premise no longer holds; the constraint is
  superseded for the thirteen `sdd-*` ids and unchanged for the two provider
  roles.
- **L9 (verification finding, 2026-10-16):** the independent verifier found that
  `lib.subtractLists a b` is `b \ a`, inverting both new checks' arguments
  against their names. Corrected; see "Verification evidence".
- **L10 (user, verbatim):** "commitea y push directamente en main." — explicit
  authorization to commit and publish, overriding the repository's branch and
  pull-request convention for this change.
