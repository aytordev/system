# ADR 0019: Use Colima as the Docker Runtime Provider

Status: Accepted

## Decision

macOS hosts run Docker through Colima (`pkgs.colima`, MIT): Colima owns the engine,
the Docker socket and the default Docker context, and the client comes from
`pkgs.docker-client`, whose runtime closure already carries the Compose and Buildx
plugins. Nothing is installed from Homebrew and no commercial licence is involved.

Ownership follows [ADR-0008](0008-module-contract-v1.md). Home owns the user-facing
capabilities and exposes `enable` and `package`; Darwin owns the privileged
`/var/run/docker.sock` symlink, because `/var/run` requires system privileges and tools
that hardcode that path do not read Docker contexts; suites own the policy of which
runtime is default and how many may be enabled at once. Podman keeps its current role on
hosts that already use it.

Colima is chosen over the alternatives for three reasons: it is the only option that is
free of commercial-licence conditions on a work machine, it is packaged in the pinned
nixpkgs alongside Lima, Docker, Compose and Buildx, and Docker contexts are its documented
coexistence mechanism. Rejected: the Docker CLI against the Podman socket (a compatibility
shim rather than an engine), Docker Desktop (free only below 250 employees and $10M
revenue), OrbStack ($8 per user per month for commercial use), and Apple's `container` CLI
(not a Docker API endpoint; its compatibility layers are unpackaged).

Two behaviours of Colima 0.10.3 were observed rather than assumed, both on macOS 27.0.1
against the repo-pinned nixpkgs:

- The socket is `~/.config/colima/default/docker.sock`. The project's own FAQ documents
  `$HOME/.colima/…`; the Darwin symlink must target the observed path.
- Colima rewrites `~/.docker/config.json` on start **and** on stop, setting and clearing
  `currentContext`. Home Manager must not own that file, and the docker capability writes
  nothing under `~/.docker`.

## Consequences

- `/var/run/docker.sock` has exactly one owner. Enabling a second provider that claims the
  same path must fail closed rather than let two owners race.
- The Podman `docker-compose` shim becomes opt-in. `docker compose` never resolves through
  `PATH` — verified with a shadowing experiment — but the bare hyphenated `docker-compose`
  is a real collision, so it belongs to Docker only when the docker capability is enabled.
- Compose and Buildx need no wiring: `home.packages = [pkgs.docker-client]` is the whole
  client story. Maintaining a `~/.docker/cli-plugins` tree would be inventing work the
  packaging already does.
- Each container tool comes from exactly one source. Homebrew's `bin` precedes the Nix
  profile on the active hosts, so a Homebrew `docker`, `docker-compose` or `colima` would
  silently shadow the managed one.
- Both runtimes are start-on-demand VMs: the Colima profile is 1.2 GB on disk and about
  1.35 GB resident for a 2 GiB profile, and a host that does not need Docker pays nothing.
- Reversing this provider means re-pointing the socket owner and the competing-name
  policy, not just swapping a package.
- Colima is MIT but effectively maintained by one person; the provider stays behind a
  capability so it can be replaced without editing its consumers.
