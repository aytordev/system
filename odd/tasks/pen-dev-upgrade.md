# Feature: pen-dev-upgrade

## Intent and authorization

Replace the stale `pencil-dev` package with `pen-dev` 1.2.14 so the flake tracks
the upstream rebrand (Pencil -> pen.dev) instead of a retired legacy asset.

User authorized this work on 2026-09-27, choosing explicitly to "alinearnos con el
upstream": rename the package attribute `pencil-dev` -> `pen-dev`, update the
overlay-composition check and the darwin development suite, and bump to the
current release. Authorized scope is repository source changes plus local
work-unit commits on a dedicated branch.

Not authorized: push, PR creation, merge, `darwin-rebuild switch` / any system
activation, and any write to `/Applications`, `/nix/store`, or user data.

Branch: `feat/pen-dev-upgrade`, based on `main` (`9475473`), which is in sync
with `origin/main`. The previously checked-out `chore/upgrade-gentle-stack`
branch is untouched and already in sync with its remote; this work does not ride
on it so the review unit stays independent.

## Problem statement and evidence

The installed app prompted "update to Pen.dev". Investigation on 2026-09-27:

| Fact | Value |
| --- | --- |
| Installed bundle | `/Applications/Nix Apps/Pencil.app`, byte-identical to `/nix/store/qdz351vid7xslsavk6bzdia7zb1pqfbb-pencil-dev-1.1.63/Applications/Pencil.app` |
| Installed version | `CFBundleShortVersionString` = **1.2.0** |
| Declared Nix version | `version = "1.1.63"` (stale label; not the bundle version) |
| Pinned asset | `https://www.pencil.dev/download/Pencil-mac-arm64.dmg`, 361,289,372 B, `Last-Modified: 2026-07-20` = release asset `Pencil-1.2.0-mac-arm64.dmg` |
| Old update channel | `app-update.yml` -> `highagency/pencil-desktop-releases`; last release v1.2.0 (2026-07-20) |
| New update channel | `highagency/pen-desktop-releases`; latest **v1.2.14** (2026-09-23) |
| Served `pen.dev/download/Pen-mac-arm64.dmg` | 408,116,951 B, identical to release asset `Pen-1.2.14-mac-arm64.dmg` |
| `pencil.dev` | redirects to `pen.dev/downloads` (rebrand announced 2026-09-17) |

Two defects follow from the above, independent of the rename:

1. `src.url` is an unversioned *latest* alias pointing at a legacy asset no longer
   listed on the downloads page. It still resolves byte-for-byte (the pinned hash
   validates today), but it is a silent-breakage hazard: when upstream retires it,
   the derivation fails with a hash mismatch and no version signal.
2. The bundle name changes `Pencil.app` -> `Pen.app`, so a version bump alone
   would break `installPhase` (`cp -r "Pencil.app"`).

## Verified facts about the new release (inspected, not assumed)

Downloaded `Pen-1.2.14-mac-arm64.dmg` from the immutable GitHub release URL and
mounted it read-only:

- `sha256` = `e5ee59e928c07ce66b817c6d56a224abe8eca8eefaa8cf163b4f0d7c4abb2e2c`,
  matching the GitHub asset digest exactly. SRI for `fetchurl`:
  `sha256-5e5Z6SjAfOZrgXxtVqIkq+jsqO76qM8WO08NfEq7Liw=`.
- Volume contains `Pen.app` and an `Applications` symlink. Executable
  `Contents/MacOS/Pen`; `CFBundleName = Pen`;
  `CFBundleShortVersionString = CFBundleVersion = 1.2.14`.
- **`CFBundleIdentifier` is still `dev.pencil.desktop`** (unchanged by the
  rebrand). Consequence: this is an in-place replacement of the same app
  identity, so `~/Library/Application Support/Pencil` (existing logins for
  Claude/Codex/Gemini/Cursor) and preferences are preserved; no data migration,
  no parallel install, no duplicate-identity conflict.
- `app-update.yml` now targets `owner: highagency`, `repo: pen-desktop-releases`,
  `updaterCacheDirName: pen-updater`. The new build's own updater points at the
  active channel, which is what "aligned with upstream" means operationally.
- `LSMinimumSystemVersion = 13.0`; host is macOS 27.0, so the floor is satisfied.
- `Pen.app` shell is ~997 MB; the dmg is 408,116,951 B.

Lifecycle note: `/Applications/Nix Apps` is populated by
`rsync --delete --copy-unsafe-links --archive --chmod=-w --no-group --no-owner`
from the system profile (`darwin-system` activation, "Set up applications").
A renamed package therefore removes the stale `Pencil.app` copy automatically at
activation; no manual cleanup step is required.

## Design contracts

- The package directory name is the attribute name
  (`lib.filesystem.packagesFromDirectoryRecursive` in `flake/packages/default.nix`),
  so the rename is expressed by renaming `packages/pencil-dev` to
  `packages/pen-dev`. No registry list needs editing.
- `src` must be an immutable, versioned release asset. The site alias
  `pen.dev/download/Pen-mac-arm64.dmg` is intentionally **not** used, because it
  reintroduces defect 1.
- Every reference to the old attribute name must change atomically in the same
  work unit; a partial rename leaves `checks/overlay-composition` asserting a
  nonexistent attribute and the darwin suite referencing a missing package.
- `meta.homepage` follows upstream identity (`https://pen.dev`). The description
  "Design on canvas. Land in code." is still the current upstream tagline.
- The historical provenance note in `odd/tasks/pen-design-skills.md` ("Pencil
  1.2.0; Nix package label 1.1.63") records what was true during that feature and
  is deliberately left unedited; this document supersedes it for current state.

## Routing, TDD and delivery

TDD does not apply: the change is a packaging rename plus a version/asset bump
with no behavioral unit under test. The available evidence is evaluation and
build-time checks, which are the correct proportionate verification here.

Delegation: multi-file write rule fired (`packages/pen-dev/package.nix`,
`checks/overlay-composition/default.nix`,
`modules/darwin/suites/development/default.nix`, `packages/README.md`,
`README.md`). Parent planned and will verify; a scoped writer performs the edit
without committing. Independent verification is delegated to the read-only
verifier.

## Tasks

- [x] **PEN-1** Reconnaissance, evidence capture, and planning checkpoint.
      Commit `0695983`.
- [x] **PEN-2** Rename the package to `pen-dev` 1.2.14 and update every reference
      in one atomic work unit. Deliverables: renamed directory, repinned
      immutable release URL and hash, `Pen.app` install path, updated check
      assertion, updated suite reference, updated package lists. Commit
      `8f9670c`, five paths.
- [x] **PEN-3** Independent verification: `nix fmt` cleanliness, package build,
      overlay-composition check, flake evaluation on both systems. All checks
      pass, see Evidence.
- [ ] **PEN-4** Record evidence, commit identities and the delivery decision here.
- [ ] **PEN-5** Native review preflight for the candidate, per the RDD switch
      state read from `gentle-ai review mode status` (read back: `on`, decided
      by default, no global or clone-local override).

## Verification plan

1. `nix fmt` (formatting; the writer runs it, the verifier confirms no diff).
2. `nix build .#pen-dev --no-link` — proves the derivation evaluates, the hash
   matches, `Pen.app` is the real bundle name, and the rename propagated to
   `flake.packages.aarch64-darwin`.
3. `nix build .#checks.aarch64-darwin.overlay-composition --no-link` (or the
   equivalent evaluated check) — proves the updated assertion passes and the
   overlay still exposes the package to `darwin.pkgs.aytordev`.
4. `nix eval --raw .#darwinConfigurations.wang-lin.config.environment.systemPackages`-style
   confirmation that the suite resolves `pkgs.aytordev.pen-dev` without
   evaluation error; `nix flake check --override-input secrets path:./checks/fixtures/secrets`
   as the CI-style gate, if it completes in this environment.
5. Confirm no residual `pencil-dev` reference remains in tracked source
   (`git grep -n pencil-dev`), excluding the historical skill-provenance note.

## Risks and open items

- A full `nix flake check` is heavy on darwin; if it cannot complete, the partial
  results and the exact failure must be reported rather than implied success.
- Activation is not performed, so the stale `/Applications/Nix Apps/Pencil.app`
  copy still exists on the host until the user rebuilds. That is expected and
  outside this authorization.
- The upstream rebrand reuses the old bundle identifier. If upstream later
  assigns a new identifier, user data would split; not the case for 1.2.14.

## Evidence and next action

Candidate: branch `feat/pen-dev-upgrade`, commits `0695983` (plan) and `8f9670c`
(implementation). Nothing pushed; no PR opened; no activation performed.

Implemented change (`8f9670c`, 5 paths):

- `packages/pencil-dev/package.nix` -> `packages/pen-dev/package.nix`: `pname`
  `pen-dev`, `version` `1.2.14`, immutable release `src`, `cp -r "Pen.app"`,
  `homepage` `https://pen.dev`.
- `checks/overlay-composition/default.nix`: assertion `"pencil-dev"` -> `"pen-dev"`.
- `modules/darwin/suites/development/default.nix`: `pkgs.aytordev.pencil-dev` ->
  `pkgs.aytordev.pen-dev`.
- `packages/README.md`, `README.md`: package lists updated.

Observed verification results (commands run against the committed candidate):

| Check | Command | Result |
| --- | --- | --- |
| Attribute rename | `nix eval --raw .#pen-dev.pname` / `.#pen-dev.version` | `pen-dev` / `1.2.14` |
| Derivation build | `nix build .#pen-dev --no-link --print-out-paths` | PASS, `/nix/store/z9hn1rm3vqcyr6al2fzd6mx5xrplbaab-pen-dev-1.2.14` |
| Built bundle | `PlistBuddy` on the build output | `CFBundleShortVersionString` 1.2.14; `CFBundleIdentifier` `dev.pencil.desktop`; `Contents/MacOS/Pen`; `Applications/` holds only `Pen.app` |
| Formatting | `nix build .#checks.aarch64-darwin.treefmt --no-link` | PASS (`treefmt-check` built) |
| Overlay assertion | `nix build .#checks.aarch64-darwin.production-overlay-composition --no-link` | PASS (`overlay-composition-tests` built) |
| All packages | `nix build .#checks.aarch64-darwin.package-builds --no-link` | PASS (`package-builds-aarch64-darwin` built) |
| Suite evaluation | `nix build .#darwinConfigurations.wang-lin.system --no-link --dry-run` | PASS, exit 0, `darwin-system-26.11.4cff07d.drv` resolved |
| CI-style gate | `nix flake check --override-input secrets path:./checks/fixtures/secrets` | `all checks passed!` (with the expected notice that `x86_64-linux` was omitted) |
| Residual refs | `grep -rn "pencil-dev" --include="*.nix" --include="*.md" .` | No hits outside this document and the historical provenance note |

The pinned hash was validated end to end: the derivation's `fetchurl` accepted the
verified SRI hash, so the immutable release asset matches the bytes inspected
before planning. `Pen.app` was found by `installPhase`, which confirms the bundle
name change was handled.

Routing note for the record: the multi-file write and the independent
verification were delegated as required, but both delegated runs were killed by a
harness stall (the writer's launcher stalled twice; its second run did complete
the edit and returned its evidence, while the verifier stalled after one call and
returned nothing). Verification was therefore executed inline by the parent. The
checks above are the parent's own observed output, not a delegated report.

Next action: native review preflight (PEN-5), then the user decides on push, PR,
and rebuild. The host still has the old `Pencil.app` copy under
`/Applications/Nix Apps` until the next `darwin-rebuild switch`; the activation
`rsync --delete` step removes it automatically at that point.

## Delivery decision

No push, no PR, no merge, and no activation are authorized by this document.
Work-unit commits stay local on `feat/pen-dev-upgrade`. If the user accepts the
candidate, the rebuild command is `just darwin-switch wang-lin`, which replaces
`Pencil.app` with `Pen.app` in place; the unchanged bundle identifier means no
user-data migration and no re-authentication in the app.

## Sources

- `https://api.github.com/repos/highagency/pen-desktop-releases/releases` (v1.2.14)
- `https://api.github.com/repos/highagency/pencil-desktop-releases/releases` (last v1.2.0)
- `https://github.com/highagency/pen-desktop-releases/releases/download/v1.2.14/Pen-1.2.14-mac-arm64.dmg`
- `https://www.pen.dev/downloads`
- `https://docs.pen.dev/getting-started/installation`
- Local: `packages/pencil-dev/package.nix`, `flake/packages/default.nix`,
  `checks/overlay-composition/default.nix`,
  `modules/darwin/suites/development/default.nix`, `packages/README.md`,
  `README.md`, `/Applications/Nix Apps/Pencil.app/Contents/Info.plist`,
  `/Applications/Nix Apps/Pencil.app/Contents/Resources/app-update.yml`,
  darwin-system `activate` (applications section).
