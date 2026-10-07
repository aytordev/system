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

`dockerEnable` currently means "install the Docker Desktop cask", which collides with
the new meaning "the docker capability is on". The Darwin cask flag becomes
`dockerDesktopEnable`; `dockerEnable` at the home suite means the Docker CLI + engine.

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
- [ ] T3 — New home capability `aytordev.programs.terminal.tools.docker`
      (`package = pkgs.docker-client`, which already bundles the Compose and Buildx
      plugins in its runtime closure; the capability writes nothing under `~/.docker`).
      Add `pkgs.docker-compose` to `home.packages` only if the hyphenated name must
      belong to Docker, which is exactly what makes the Podman shim opt-in (D3/T5).
- [ ] T4 — New home capability `aytordev.programs.terminal.tools.colima`
      (`package = pkgs.colima`; no autostart by default — `brew services` is not
      available to a nixpkgs install, so decoration is either manual `colima start` or
      an explicit Home Manager launchd agent).
- [ ] T5 — Make the podman-compose shim opt-in and keep the `containers.conf` provider
      pin; reference ADR 0019 from `modules/home/AGENTS.md` and `modules/darwin/AGENTS.md`
      so the container-runtime protocol is discoverable next to the code it governs.
- [ ] T6 — Darwin: privileged `/var/run/docker.sock` adapter (idempotent activation)
      plus the rename of the cask flag to `dockerDesktopEnable`, and a conflict
      assertion when the Desktop cask is enabled together with Colima.
- [ ] T7 — Home `development` suite: compose `dockerEnable`/`dockerDesktopEnable`/
      `podmanEnable` with `mkDefault`; single default runtime; no silent overlap.
- [ ] T8 — Checks: register the new capabilities in `checks/module-contract`, replace
      the `dockerEnable` portability assertion with the new invariant, extend
      `tests/default.nix` synthetic options.
- [ ] T9 — Regenerate `checks/docs-generation/golden/{darwin,home}.txt`.
- [ ] T10 — Verification: `nix flake check --override-input secrets
      path:./checks/fixtures/secrets` and
      `nix build .#darwinConfigurations.civislend.system`.
- [ ] T11 — Host functional verification after the user runs
      `just darwin-switch civislend`: `docker run`, `docker compose up`, `podman run`,
      `docker context ls`. Then update README/AGENTS docs.

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
