# Feature: pen-mcp-registry

## Intent and authorization

Expose the Pen (pen.dev) desktop MCP server to Pi so a Pi session can read and
edit the `.pen` document that is open in a running Pen app, and make that wiring
declarative in Nix instead of hand-edited at runtime.

User authorized this work on 2026-09-30, answering two explicit decisions:

1. Where to work: an **isolated worktree** `../system-pen-mcp` on branch
   `feat/pen-mcp-registry` based on `main` (`ffdcda0`), because the main
   worktree carries in-flight, uncommitted `bitwarden-state-file-ownership`
   work that this feature must not touch.
2. File ownership: **Nix owns `~/.config/mcp/mcp.json`** (the standard
   user-global MCP registry imported by Pi's MCP adapter). Nix must NOT write
   `~/.pi/agent/mcp.json`, which the official Gentle AI installer owns.

Authorized scope: repository source changes (new home modules, one home
enable-line, documentation) plus work-unit commits on `feat/pen-mcp-registry`.

Not authorized: push, PR creation, merge, `darwin-rebuild switch` or any system
activation, any write to `/Applications`, `/nix/store`, `~/.config/mcp`,
`~/.pi/agent/mcp.json`, or the Pen app's configuration, and any change to the
in-flight bitwarden work.

## Problem statement and evidence

Question answered by investigation: *does Pen ship an MCP integration for Pi?*
No, and the finding is recorded in Engram as
`research/pen-design-skills/pi-mcp-integration`.

### Evidence 1 — Pen's supported MCP clients (app 1.2.14)

The packed client map in `/run/current-system/Applications/Pen.app/Contents/Resources/app.asar`
lists `claudeCodeCLI, codexCLI, geminiCLI, cursorCLI, openCodeCLI, windsurfIDE,
antigravityIDE, antigravity, copilotIDE, kiroCLI, claudeDesktop`. There is no Pi
target. The 86 `.pi/agent` / `pi-coding-agent` hits elsewhere in the bundle are
Pen's *embedded* Pi runtime (`@earendil-works/pi-coding-agent`), not an
installation target.

### Evidence 2 — the exact invocation Pen installs (delegated read-only extraction)

Extracted from the bundled `@ha/mcp` writer, `PENCIL_MCP_NAME = "pencil"`:

| Field | Value |
| --- | --- |
| `command` | `<Pen.app>/Contents/Resources/app.asar.unpacked/out/mcp-server-darwin-arm64` |
| `args` | `["--app", "desktop"]` |
| `env` | `{}` |
| `type` | `stdio` |
| config key | `mcpServers.pencil` (Codex: `mcp_servers`, OpenCode: `mcp`) |

The socket path is never passed as an argument: the binary derives
`~/.pencil/socket/pencil-desktop.sock` from `--app desktop`. The app spawns
nothing itself; each client launches the binary as its own child over stdio.

Confirmed locally: `~/.pencil/socket/pencil-desktop.sock` exists, and
`/nix/store/z9hn1rm3vqcyr6al2fzd6mx5xrplbaab-pen-dev-1.2.14/Applications/Pen.app/Contents/Resources/app.asar.unpacked/out/mcp-server-darwin-arm64`
is present in the store.

### Evidence 3 — how Pi consumes MCP config (`pi-mcp-adapter`)

- `loadMcpConfig()` merges every source returned by `getConfigSources()`, in
  order: `~/.config/mcp/mcp.json` (label *user-global standard MCP*,
  `shared: true`), `~/.agents/mcp.json`, `~/.agents/mcp/mcp.json`, then
  `~/.pi/agent/mcp.json` (Pi-owned, highest precedence).
- That shared file is loaded unconditionally; `settings.hostConfigDiscovery`
  only gates the *other* host files (Claude/Codex/OpenCode/…).
- The adapter's write path for imported sources is `~/.pi/agent/mcp.json`, so
  nothing in the toolchain writes `~/.config/mcp/mcp.json`.
- `validateConfig` accepts a permissive server entry (`isServerEntry` only
  requires an object), so `{"command": ...}` plus optional fields is safe.

### Follow-up boundary (not in scope)

`~/.pi/agent/mcp.json` remains installer-owned and still carries `context7` and
`engram` (the latter through a hand-written wrapper to work around the
`home.sessionVariables` guard bug recorded in Engram
`pi/engram/data-dir-guard-split`). Bringing those two under Nix ownership is a
separate change.

## Design

Two new capability/registry modules under home-manager (auto-discovered by
`importModulesRecursive ../../modules/home`):

1. `modules/home/programs/terminal/tools/mcp/default.nix` — **pure-data
   registry** (theme-style, no `enable`; the output exists only when
   `servers != {}`): `aytordev.programs.terminal.tools.mcp.servers` generates
   `xdg.configFile."mcp/mcp.json"`, the standard user-global MCP registry.
2. `modules/home/programs/terminal/tools/pen/default.nix` — **capability** with
   `enable` and `package`: wraps Pen's MCP server as `pen-mcp` (deriving its
   path from the `pen-dev` store path and baking in `--app desktop`), installs
   it, and contributes `servers.pencil` when `mcp.enable` is true.

Ownership rule stated in both module headers: Nix owns the shared registry and
the wrapper; it never writes Pi's installer-owned `~/.pi/agent/mcp.json`.

## Tasks

| ID | Task | Status |
| --- | --- | --- |
| PENMCP-1 | Record discovery evidence (asar argv + adapter merge semantics) in this document and Engram | done |
| PENMCP-2 | Add `tools/mcp` pure-data registry module | done |
| PENMCP-3 | Add `tools/pen` capability module (wrapper + registry contribution) | done |
| PENMCP-4 | Enable `pen` on the `aytordev@wang-lin` home | done |
| PENMCP-5 | Update `modules/home/AGENTS.md` tool inventory, module headers, module-contract check and option-docs golden index | done |
| PENMCP-6 | Verify: `nix fmt`, evaluate the generated registry file, live MCP handshake against the wrapper, CI-style `nix flake check` | done |

## Verification evidence

| Check | Command | Result |
| --- | --- | --- |
| Formatting | `nix fmt` | `formatted 362 files (1 changed)`; the change was alejandra's `inherit (server) …` rewrite of the new registry module |
| Generated registry | `nix eval --raw '.#homeConfigurations."aytordev@wang-lin".config.xdg.configFile."mcp/mcp.json".text'` | `{"mcpServers":{"pencil":{"command":"/nix/store/15vlbp4gizpam77yba14dv7vadbbgajl-pen-mcp/bin/pen-mcp","type":"stdio"}}}` |
| Materialized file | `nix build --no-link --print-out-paths '.#homeConfigurations."aytordev@wang-lin".activationPackage'` | build succeeded; `home-files/.config/mcp/mcp.json` links to the rendered file with the same content |
| Wrapper argv | `cat $(…)/bin/pen-mcp` | `exec "<pen-dev-1.2.14>/…/out/mcp-server-darwin-arm64" --app desktop "$@"` |
| Live MCP handshake | MCP SDK client (`@modelcontextprotocol/client` 2.0.0) spawning the wrapper, with the Pen app running | connected to `~/.pencil/socket/pencil-desktop.sock`; server `pencil` 1.0.0; `tools/list` → `browser, execute, get_app_state, get_style, read_skill` |
| Repository checks | `nix flake check --override-input secrets path:./checks/fixtures/secrets` | `all checks passed!` (x86_64-linux omitted as incompatible, per the flake's own note) |
| Targeted checks | `integration-module-contract`, `integration-home-module`, `production-home-aytordev-wang-lin`, `treefmt` | all built |

Honest limits of this verification:

- The handshake ran with the Pen app already running. No attempt was made to
  launch, kill, or reconfigure the app, and the app-closed failure mode is still
  only known statically (the server starts, then retries the app connection).
- The Pi side was verified at the adapter layer (the shared source is read, the
  path is the one it resolves). No live Pi session was reloaded to call a Pen
  tool, because that requires restarting the user's Pi process.
- `nix flake check` skips the incompatible `x86_64-linux` systems; the new
  modules are platform-guarded, and the macOS-only assertion covers the `pen`
  capability.

## Delivery decision

Nothing is pushed, no pull request is opened, no `darwin-rebuild switch` or
home activation is run, and the in-flight `bitwarden-state-file-ownership`
worktree and branch are untouched. Activating this on the host means running the
normal rebuild once the user decides; until then the generated file exists only
in the store.

Commit: `365fa46` (`feat(home): bridge Pen's MCP server into a declarative MCP registry`)
on `feat/pen-mcp-registry`.

## Open questions / known limits

- Pen's Go MCP server has no documented guarantee for third-party clients: it is
  version-coupled to the installed app and unsupported by upstream. A Pen
  release can change the argv contract silently. The wrapper isolates that
  contract in one place.
- Whether the server keeps running with the app closed vs. failing lazily on
  tool calls is still not established: the verified handshake had the app
  running, and the server logs a connection to the socket at startup. What it
  does without a live app remains an open, low-consequence question, because a
  Pi session can only use Pen tools with the app open anyway.
- Enabling this on `avicente@civislend` is deliberately out of scope: that host
  installs `pen-dev` through the darwin development suite but the work user does
  not use Pen.

## Sources

- `/run/current-system/Applications/Pen.app` (1.2.14), `Contents/Resources/app.asar`
  and `app.asar.unpacked/out/mcp-server-darwin-arm64`
- `~/.pi/agent/npm/node_modules/pi-mcp-adapter/config.ts` (`getConfigSources`,
  `loadMcpConfig`, `isExclusiveConfigMode`, `readValidatedConfig`)
- `https://docs.pen.dev/getting-started/installation`,
  `https://docs.pen.dev/getting-started/ai-integration`
- `packages/pen-dev/package.nix`, `modules/home/programs/terminal/tools/engram/default.nix`
  (wrapper precedent), `docs/decisions/0008-module-contract-v1.md`
