# Docker Runtime

## Goal

Make a real Docker engine available on `civislend` (work host, `aarch64-darwin`,
macOS 27.0.1) without breaking the Podman runtime that already works, without a
commercial license dependency, and without Homebrew owning any CLI tool.

Driving problem: projects in this workflow invoke `docker` and `docker-compose`.
Today the repo publishes only a `docker-compose` shim that forwards to
`podman compose` (`modules/home/programs/terminal/tools/podman-compose/default.nix:13-16`).
There is no `docker` binary and no Docker daemon, so any project calling
`docker build` / `docker run` / `DOCKER_HOST` fails.

## Current state (evidence)

- `docker` → `command not found`; `/var/run/docker.sock` and
  `~/.docker/run/docker.sock` do not exist.
- `podman 5.8.7` (Nix store) + `podman machine` `podman-machine-default`
  (applehv, 4 CPU / 6 GiB / 100 GiB), start-on-demand (stopped at time of analysis).
- Home side: `modules/home/suites/development/default.nix:71-73,133-134` installs
  `podman`, `podman-tui`, and enables `lazydocker` + `podman-compose` from
  `cfg.podmanEnable`.
- Darwin side: `modules/darwin/suites/development/default.nix:12,25-29` exposes
  `dockerEnable` (cask `docker-desktop`) and `podmanEnable` (cask `podman-desktop`);
  `modules/darwin/archetypes/workstation/default.nix:19-20` defaults docker off,
  podman on.
- `checks/module-contract/default.nix` registers `programs.terminal.tools.podman-compose`
  and `programs.terminal.tools.lazydocker`, but there is no docker capability.
- `checks/home-portability/default.nix:255` asserts home has **no** `dockerEnable`.
- Verified in the pinned nixpkgs: `docker-client` 29.8.1 (`bin/docker` only, **no**
  `cli-plugins`), `docker-compose` 5.5.1 (`bin/docker-compose`, meta: "Docker CLI
  plugin to define and run multi-container applications"), `colima` 0.10.3,
  `lima` 2.2.0, `nerdctl` 2.4.1.
- Verified absence: no brew cask `rancher-desktop`, no cask for Apple's `container`
  CLI, no `nixpkgs#apple-container`.
- Verified plugin layout in the pin: `docker-compose` 5.5.1 ships
  `bin/docker-compose -> ../libexec/docker/cli-plugins/docker-compose` and runs
  standalone (`Docker Compose version 5.5.1`, usage `docker compose ...`);
  `docker-buildx` 0.35.0 ships the same layout. `docker-client` ships `bin/docker`
  only, with no bundled plugins.
- Verified from Colima's own FAQ: full Docker compatibility; Colima becomes the
  default Docker context automatically since v0.3.0; the socket is
  `$HOME/.colima/default/docker.sock` since v0.4.0; the documented remedies for an
  app that cannot find the daemon are an app-specific socket path, `DOCKER_HOST`, or
  "create a symlink to the default location"; Colima bundles **neither** Compose nor
  Buildx and directs the user to link them into `~/.docker/cli-plugins/`; macOS 13+
  is required; autostart is documented as `brew services start colima`, which does not
  apply to a nixpkgs install.
- Verified on host, T1 spike (2026-10-07, `civislend`): Colima 0.10.3 and Lima 2.2.0
  from the **repo-pinned** nixpkgs (`151fa4e8`) start with `--vm-type vz` on macOS
  27.0.1 (Apple Virtualization.Framework, aarch64, virtiofs). `docker run hello-world`
  and a real `docker compose up` / `logs` / `down` cycle succeeded; engine 29.5.2 served
  client 29.8.1; `docker compose` reports 5.5.1 and `docker buildx` 0.35.0 with no wiring
  of any kind. With the podman machine also up, both engines ran containers concurrently
  and each listed only its own.
- **`pkgs.docker-client` already bundles the plugins.** Its runtime closure contains
  `docker-compose` 5.5.1 and `docker-buildx` 0.35.0, and the CLI resolves both from their
  store `libexec/docker/cli-plugins` paths even under `env -i` with only its own `bin` on
  `PATH`, no `~/.docker/cli-plugins` and no `DOCKER_*` variable. A fake `docker-compose`
  placed first on `PATH` was ignored, so `docker compose` is not resolved through `PATH`.
- **The documented socket path is wrong for this version.** Colima 0.10.3 keeps its home
  in `~/.config/colima/` and exposes
  `unix:///Users/avicente/.config/colima/default/docker.sock`, not the
  `$HOME/.colima/default/docker.sock` the FAQ states. T6 must target the real path and the
  ADR must not copy the FAQ.
- **Colima mutates `~/.docker/config.json` at start *and* stop.** It wrote
  `{"auths": {},"currentContext": "colima"}` on start and dropped `currentContext` on
  stop, leaving `{"auths": {}}`.
- Footprint: the running VM accounted for ~1.35 GB RSS against a 2 GiB profile; the
  profile directory is 1.2 GB on disk and survives `colima stop`, so a later
  `colima start` does not re-download the image.
- `/var/run/docker.sock` still does not exist, so tools that hardcode it need the T6
  privileged symlink to the Colima socket.
- Verified PATH order on this host: `/opt/homebrew/bin` (38) precedes
  `/Users/avicente/.nix-profile/bin` (41), `/etc/profiles/per-user/avicente/bin` (42)
  and `/usr/local/bin` (45).

## Decisions

### D1 — Runtime: Colima provides the Docker daemon

`colima` (MIT, `nixpkgs#colima` 0.10.3) runs a Lima VM exposing a real Docker engine
and a Docker context; the `docker` CLI and the Compose plugin come from nixpkgs.

Rationale:

- **It is Docker, not a Docker-shaped shim.** The request is for Docker itself, so a
  Podman socket with a Docker-API facade does not satisfy it.
- **No license risk.** Docker Desktop is free only for organizations with fewer than
  250 employees **and** under $10M annual revenue; OrbStack requires $8/user/month for
  business and commercial use (personal use only is free, 30 days of trial first). This
  is a work machine and the employer's scale is unknown, so taking on a paid-license
  dependency is an unverifiable assumption.
- **It matches the repo's own rules.** `modules/darwin/AGENTS.md` says to avoid
  Homebrew for CLI tools available in nixpkgs. Colima, Lima, `docker-client` and
  `docker-compose` are all in the pinned nixpkgs, so no cask is needed and versions
  stay pinned by `flake.lock`.
- **Contexts make coexistence a first-class feature.** Colima's own FAQ documents
  coexistence with other engines through Docker contexts.
- **On-demand VM.** Consistent with the existing podman machine, which is also not
  always running; RAM is only paid when a project needs it.

Rejected, with reasons:

- **Docker CLI against the Podman machine's Docker-compatible socket.** Cheapest option
  (zero new VMs, zero licenses), but it keeps the current workaround instead of
  delivering a real engine, and compatibility with Compose v2 features (BuildKit,
  network and volume semantics) is partial. Kept as a fallback if Colima fails.
- **Docker Desktop (cask).** Already reachable through a flag, but it is a paid
  license question on a work machine and it installs a privileged `/var/run/docker.sock`
  symlink plus a second always-on daemon.
- **OrbStack (cask).** Best Apple Silicon UX, but commercial use is a purchase
  decision that is not ours to make, and it would add a third container GUI next to
  Podman Desktop.
- **Apple `container` CLI.** Not a Docker Engine or Docker API endpoint; it needs
  third-party compatibility layers (`socktainer`, `gocker`) that exist neither in the
  pinned nixpkgs nor as brew casks.

### D2 — Split ownership across layers (ADR 0008 compliance)

- **Home (capability)** owns the CLI: `docker-client` (which already carries the Compose
  and Buildx plugins in its runtime closure), and `colima` as the provider CLI. Both
  expose `enable` and `package` per the Capability contract, and neither writes anything
  under `~/.docker`.
- **Darwin (platform adapter)** owns the privileged `/var/run/docker.sock` symlink to
  the Colima socket, because `/var/run` requires system privileges. Home Manager never
  writes it.
- **Suite** owns policy: which runtime is the default, and how many runtimes are
  allowed at once.

### D3 — Compose and Buildx need no wiring; only the hyphenated name needs a decision

Verified on host (T1): `pkgs.docker-client`'s **runtime closure already contains**
`docker-compose` 5.5.1 and `docker-buildx` 0.35.0, and the CLI resolves both as plugins
from their store `libexec/docker/cli-plugins` paths, including in a clean environment.
Therefore:

- Nothing is linked into `~/.docker/cli-plugins`. `home.packages = [pkgs.docker-client]`
  is the whole CLI story, and `docker compose` / `docker buildx` work out of the box.
- `docker-client` publishes **no** `bin/docker-compose`, so it cannot collide with the
  Podman shim, and a shadowing experiment proved `docker compose` does not resolve through
  `PATH`.
- The only open item is the **bare hyphenated `docker-compose`**, which the Podman shim
  owns today. Adding `pkgs.docker-compose` to `home.packages` is a genuine build collision
  on that path, so the shim becomes **opt-in** (`dockerComposeShim`, default `false`) and
  Docker owns the hyphenated name only when the docker capability is enabled.

### D4 — Disambiguate the flag names

The Darwin cask flag becomes `dockerDesktopEnable`; the Home capability
`aytordev.programs.terminal.tools.docker` is what actually means "docker is available".

**No home suite flag is added.** `checks/home-portability/default.nix:255` asserts that the
home development suite has no `dockerEnable`, next to `azureEnable`, `gameEnable`,
`goEnable` and `sqlEnable`: platform and host decisions do not become home booleans. The
runtime choice is therefore expressed directly on the capabilities, and each concrete host
selects it — which is both ADR-0008-compliant and more precise than one flag standing for
two programs.

### D6 — Who publishes the hyphenated `docker-compose`

Exactly one package may publish `bin/docker-compose` in `home.packages`; two is a build
collision. The rule: **Docker owns the Docker name whenever the docker capability is
enabled**. `docker` publishes `pkgs.docker-compose` (the Compose binary, which also serves
the `docker compose` subcommand form as the plugin already inside `docker-client`), and the
Podman shim serves the legacy name only on hosts with no Docker. The suite derives both
sides with `mkDefault` and asserts if the two are ever explicitly requested together.

### D7 — The privileged socket adapter publishes, never clobbers

A Darwin adapter owns `/var/run/docker.sock`, pointing at the Colima socket, because
tools that hardcode that path ignore Docker contexts. It is idempotent and refuses to
replace an entry it does not own, and the pair (Docker Desktop cask + this adapter) is
rejected by an evaluation-time assertion. The symlink dangles while the Colima VM is
stopped, which is the same practical outcome as the socket not existing: a running VM is a
precondition either way.

### D5 — PATH precedence is a documented hazard

Homebrew's bin precedes the Nix profile on this host, so any Homebrew-installed
`docker`, `docker-compose` or `colima` would shadow the Nix-managed ones. The ADR
records this and the runtime is installed from exactly one source: nixpkgs.

## Scope

- New home capabilities for the Docker CLI and for Colima.
- Rewritten compose-shim policy in the existing podman-compose capability.
- Darwin privileged socket adapter and the cask flag rename.
- Suite wiring, module-contract registration, portability invariant, docs golden.
- ADR 0019 recording the container runtime policy.
- Functional verification of Docker, Compose and Podman coexistence on `civislend`.

## Non-goals

- Removing or replacing Podman. It stays the default runtime on this host.
- Kubernetes runtimes (k3s, kind, minikube) and `k8sEnable` wiring.
- GUI container management beyond the Podman Desktop cask that already exists.
- Changing the private `secrets` flake or anything under `homes/` beyond the runtime
  flags.
- A NixOS implementation. `modules/nixos/` does not exist yet; the capability and the
  provider are portable, but only Darwin is exercised here.

## Tasks

- [x] T0 — Operational preflight: branch `feat/docker-runtime` created from
      `origin/main` at `97df03a8` (the merge of #234) with `--no-track`, so no accidental
      push can target `main`. The pre-existing `flake.lock` and `flake/dev/flake.lock`
      modifications were left untouched in the working tree by the user's instruction and
      are never staged by this work. Recorded:
      `fix/pi-gui-environment-stable-command` merged as PR #234 (CI green on
      `aarch64-darwin`, `x86_64-linux`, expressions and label). The worktree still
      publishes the stable command
      (`modules/home/programs/terminal/tools/pi/gui-environment.nix:25`), so a later
      `darwin-switch` from this branch cannot reintroduce the version-pinned regression.
- [x] T1 — Spike (on host, reversible): **passed**. Colima 0.10.3 from the repo-pinned
      nixpkgs started on macOS 27 with `--vm-type vz`, `docker run hello-world` and a real
      `docker compose up` / `logs` / `down` cycle succeeded, Compose 5.5.1 and Buildx
      0.35.0 resolved with no wiring, and both engines ran containers concurrently with
      the podman machine up. The host was restored afterwards: colima stopped,
      `podman-machine-default` stopped as found, scratch removed, repository untouched.
      Left behind on purpose: the 1.2 GB Colima profile in `~/.config/colima/` and a
      Colima-written `~/.docker/config.json`.
- [x] T2 — `docs/decisions/0019-container-runtime-policy.md` written in the format
      `docs/AGENTS.md` prescribes: the provider decision, ADR-0008 layer ownership, the
      rejected alternatives with their reasons, the two observed Colima behaviours, and
      the consequences (one socket owner, opt-in shim, no plugin wiring, one install
      source, start-on-demand VM cost).
- [x] T3 — `modules/home/programs/terminal/tools/docker/default.nix` created:
      `aytordev.programs.terminal.tools.docker` with `enable` and
      `package = mkPackageOption pkgs "docker-client" {}`, emitting only
      `home.packages`. The comment records why nothing is written under `~/.docker`.
      `pkgs.docker-compose` was deliberately **not** added.
- [x] T4 — `modules/home/programs/terminal/tools/colima/default.nix` created:
      `aytordev.programs.terminal.tools.colima` with `enable` and
      `package = mkPackageOption pkgs "colima" {}`. No `lima`/`qemu` added because both
      are already in colima's runtime closure, and no autostart: the comment records that
      upstream's `brew services start colima` does not apply to a nixpkgs install.
- [x] T5 — Shim made opt-in in
      `modules/home/programs/terminal/tools/podman-compose/default.nix`: a new
      `dockerComposeShim.enable` (`mkEnableOption`, default false) guards only
      `dockerComposeCompat` in `home.packages`; `package` and the `containers.conf`
      provider pin are behaviourally unchanged. The ADR references in the AGENTS.md files
      moved to T11, outside that task's edit surfaces.
- [x] T6 — **done**. `modules/darwin/services/docker-socket/default.nix` created with the
      three-branch idempotent fragment; `dockerEnable` renamed to `dockerDesktopEnable` in the
      suite, the workstation archetype and the `tests/default.nix` stub; the eval-time conflict
      assertion landed; the Darwin golden was regenerated natively and is stable under `.#`;
      ADR 0019 is referenced from `modules/darwin/AGENTS.md`. Native receipts after staging the
      new module: `integration-synthetic-darwin`, `integration-docs-generation`,
      `integration-module-contract` and `unit-architecture-layers` all build, and `nix fmt`
      changed nothing.
      Frozen spec as implemented: (a) new `modules/darwin/services/docker-socket/default.nix`
      owning `aytordev.services.docker-socket` with `enable`, `socketPath` (default
      `/var/run/docker.sock`) and a **required** `targetPath` (no derived default, so option
      evaluation never forces user identity); (b) a named
      `system.activationScripts.docker-socket` fragment that is idempotent, compares the
      current symlink target, and on a foreign owner prints a loud error and leaves it
      untouched instead of clobbering or aborting the whole activation; (c) rename
      `dockerEnable` → `dockerDesktopEnable` in the darwin suite, the workstation archetype
      and the `tests/default.nix` synthetic stub; (d) an eval-time assertion in the darwin
      development suite rejecting the Desktop cask together with the adapter; (e) reference
      ADR 0019 from `modules/darwin/AGENTS.md`.
- [x] T7 — **done**. The home suite derives `lazydocker` from either runtime and yields the
      hyphenated name whenever Docker is on, with an assertion against two owners; the docker
      capability publishes `pkgs.docker-compose`; civislend enables `docker` + `colima` and the
      socket adapter with an explicit target. Verified natively on the real host configuration:
      `docker.enable = true`, `colima.enable = true`, `dockerComposeShim.enable = false`,
      `lazydocker.enable = true`, adapter target
      `/Users/avicente/.config/colima/default/docker.sock`; home golden unchanged; five focused
      checks and the real `darwinConfigurations.civislend.system` build all pass. The delegated
      writer timed out after writing every surface and before reporting, so the parent ran the
      entire verification itself rather than accepting an unreported claim.
      Frozen spec as implemented: (a) `modules/home/suites/development/default.nix` derives
      `lazydocker.enable = mkDefault (podmanEnable || docker.enable)`,
      `podman-compose.dockerComposeShim.enable = mkDefault (podmanEnable && !docker.enable)`
      and adds an assertion rejecting docker plus the shim; (b) the docker capability
      publishes `pkgs.docker-compose` so Docker owns the hyphenated name (D6); (c) the
      host files enable the capabilities — `programs.terminal.tools.{docker,colima}.enable`
      in `homes/aarch64-darwin/avicente@civislend/default.nix` and
      `aytordev.services.docker-socket` with its explicit `targetPath` in
      `systems/aarch64-darwin/civislend/default.nix`; (d) reference ADR 0019 from
      `modules/home/AGENTS.md`; (e) confirm the home golden is unchanged.
- [x] T8 — **done**, in two units. **T8a**: new `checks/container-runtime` with six
      synthetic homes asserting the policy (podman-only yields the shim, docker-only and
      both-runtimes give the hyphenated name to Docker, lazydocker follows either runtime,
      Podman stays installed, the two-owners guard fires, package options stay replaceable,
      and nothing under `~/.docker` is managed), plus a `runCommand` body validating the real
      `docker`, `docker-compose` and `colima` artifacts with no daemon, network or VM; the two
      capabilities registered in `checks/module-contract`; the renamed archetype default locked
      in the nix-unit suite; the new check listed in `checks/AGENTS.md`. **T8b**: the privileged
      fragment is now *executed* — the adapter is evaluated standalone with `lib.evalModules`,
      published into the check's own build directory through `builtins.placeholder`, and run
      against four real filesystem states (create with a dangling target, an idempotent silent
      second run, a foreign symlink owner, a regular-file owner), each refusal leaving the entry
      untouched, naming the owner and the remediation, and exiting zero; plus the `targetPath`
      no-default contract, the disabled-adapter no-op, and the Darwin conflict guard firing only
      when both providers are requested. Both units carried a negative control that was observed
      to fail before being restored. The `!(developmentOptions ? dockerEnable)` assertion in
      `checks/home-portability` was left as is: it is the guard that forced this design and it
      already covers the decision, so the new check adds the behaviour it never had.
      Evidence: `integration-container-runtime`, `integration-module-contract`, `unit-nix-unit`
      and the Linux evaluation of the new check all pass.
- [x] T9 — **done**. `checks/docs-generation/golden/{darwin,home}.txt` were regenerated
      natively under `.#` after each task and are stable: re-running the recipe produces no
      worktree change, `integration-docs-generation` passes, and the final
      `nix flake check` builds it along with everything else.
- [x] T10 — **done**. `nix flake check --no-build --all-systems` and the full
      `nix flake check` (build every check) both report "all checks passed!" on
      aarch64-darwin, with `--override-input secrets path:./checks/fixtures/secrets`, and the
      real `darwinConfigurations.civislend.system` builds. Not covered here: an
      x86_64-linux **build** (only its evaluation), which CI performs.
- [ ] T11 — Host functional verification, after the user runs
      `just darwin-switch civislend`: `docker run`, `docker compose up`, `podman run`,
      `docker context ls`, and that `/var/run/docker.sock` exists and points at the Colima
      socket. The ADR references in the AGENTS.md files landed in T6/T7; update other
      human-facing docs only if they actually enumerate container tooling. **First attempt
      (2026-10-07) did the switch, found the dead fragment below, and requires a re-switch
      after T12 before the socket checks can run.**
      **Partial functional evidence, on the activated system without the T12 fix**: `colima
      start` works, `docker run hello-world` succeeds, `docker context show` is `colima`
      pointing at `unix:///Users/avicente/.config/colima/default/docker.sock`, and all three
      binaries are on PATH from the Home side — so the CLI path never needed the standard
      socket. Only a client that hardcodes `unix:///var/run/docker.sock` fails
      (`connect: no such file or directory`). The missing publication is therefore not a
      blocker for CLI workflows; it matters for tools that ignore Docker contexts. Still
      pending: the same functional checks after the re-switch, plus `podman run`
      coexistence.
- [x] T12 — **The host verification caught the fragment never running.**
      `/var/run/docker.sock` did not exist after the switch, and the activated
      `/run/current-system/activate` contained none of the fragment. Root cause, read from
      nix-darwin's own `modules/system/activation-scripts.nix`: its top-level activate
      script inlines a **fixed allow-list** of entry names (`preActivation` … `homebrew`,
      `postActivation`), so a custom `system.activationScripts.<name>` is a valid option
      that is never executed. Fixed by publishing through
      `system.activationScripts.postActivation.text` with `lib.mkAfter` (the entry's `text`
      is `types.lines`, so concurrent writers concatenate), and by adding a module
      assertion that the fragment is present in
      `system.activationScripts.script.text` — the script that actually runs. The check
      gained the same reachability contract (`!(… ? docker-socket)` plus the fragment being
      in `postActivation.text`). Evidence: the real civislend config now contains the
      fragment three times inside `script.text`, every entry in `config.assertions` is
      `true`, the option-docs golden is unchanged, and the full `nix flake check` reports
      "all checks passed!".
- [ ] T13 — **Open, deliberately not bundled here**: `modules/darwin/system/rosetta/default.nix`
      publishes `system.activationScripts.rosetta`, so the Rosetta 2 fragment has never run
      either — `Installing Rosetta 2` is absent from the activated script while
      `aytordev.system.rosetta.enable` is `true` on civislend. It is the same defect class as
      T12 and belongs in its own work unit, not in this feature's candidate.

## Risks and open questions

- **Colima bus factor.** MIT, 30k stars, but effectively one primary maintainer and
  ~389 open issues. Mitigation: the CLI and the engine stay replaceable (D2 keeps the
  provider behind a capability), and Podman remains installed.
- **Two VMs on a laptop.** Mitigation: size the Colima VM small and keep both
  start-on-demand; revisit if RAM pressure appears.
- **Colima on macOS 27 — validated in T1.** 0.10.3 started with `--vm-type vz` on
  macOS 27.0.1 and served Docker and Compose.
- **Compose 5.5.1 vs the engine Colima bundles — validated in T1.** Client 29.8.1
  negotiated against server 29.5.2, and `docker compose up` / `logs` / `down` ran
  against it; the bundled Buildx answered too.
- **`/var/run/docker.sock` ownership.** Docker Desktop also wants that path. The
  conflict assertion in T6 must fail closed rather than let two owners fight.
- **`~/.docker/config.json` — resolved.** Colima rewrites that file on start (adding
  `currentContext: colima`) and on stop (removing it). Home Manager must not own the file
  or the context field, and the docker capability writes nothing under `~/.docker`.
  Recorded in the ADR (T2).
- **Open question for the user:** which concrete project or tool requires Docker? If it
  only needs the CLI and a socket, the fallback (Docker CLI over the Podman socket) is
  cheaper than a second VM.
- **Unrelated dirty state** in `flake.lock` and `flake/dev/flake.lock` (15 changed
  lines, input revisions) belongs to no task here. By explicit user instruction it is left
  untouched and must not be swept into this feature's commits.
- **Delegation incident during T7.** The writer timed out after applying all five surfaces
  but before reporting. Its work was complete, so nothing was lost, but every claim in this
  document was re-verified by the parent: a timed-out writer leaves unverified surfaces, not
  accepted ones, and its partial output must never be committed on the strength of its own
  silence.
- **Operational note: `.#` cannot see untracked files.** Nix's `git+file` fetch excludes
  them, so any `.#`-based verification silently evaluates a tree without new modules.
  New capability files must be staged before `just docs-golden` or any
  `nix build .#…` check is treated as evidence; the T3–T5 receipts were re-run after
  staging for exactly that reason.
