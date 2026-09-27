# Bitwarden Password Manager

Home Manager modules for the Bitwarden password manager: the desktop app and
the CLI.

## Modules

- **Desktop app**: `modules/home/programs/desktop/security/bitwarden`
- **CLI**: `modules/home/programs/terminal/tools/bitwarden-cli`

Both are capability modules under `aytordev.*`.

## Desktop Application

Enable the Bitwarden desktop app:

```nix
aytordev.programs.desktop.security.bitwarden.enable = true;
```

Available options (see the module for full descriptions):

- `enableBrowserIntegration` (default `true`)
- `enableSystemStartup` (default `false`)
- `enableTrayIcon` (default `true`)
- `biometricUnlock.enable` (default `false`, Touch ID on macOS)
- `biometricUnlock.requirePasswordOnStart` (default `true`)
- `vault.timeout` (minutes, default `15`, `null` = never)
- `vault.timeoutAction` (`"lock"` | `"logout"`, default `"lock"`)
- `settings` — raw data.json overrides (e.g. `theme`), applied as first-run
  defaults (see below)
- `package` / `installPackage` — package and install strategy

**Platform notes:**

- On Darwin the desktop app is managed as a Homebrew cask (to avoid nixpkgs
  Electron build failures); `installPackage` defaults to `false`.
- On Linux the package is installed via Home Manager; `installPackage` defaults
  to `true`.

**Settings are a first-run seed:**

`data.json` is Bitwarden's mutable `electron-store` state file: alongside the
declared settings it carries `stateVersion`, window geometry and cached server
feature flags, and the application rewrites it on every launch. Home Manager can
only symlink a store path into place, and store paths are read-only, so owning
that file breaks the application's startup migration (`EACCES`).

The module therefore publishes the declared settings as a read-only seed under
`.local/share/aytordev/bitwarden-desktop/data.json` and a `bitwardenStateFile`
activation entry copies it to the application's state path (`data.json` in
`~/Library/Application Support/Bitwarden` on Darwin,
`$XDG_CONFIG_HOME/Bitwarden` on Linux) only while Bitwarden does not own that
file yet. From then on Bitwarden owns the file.

The trade-off: changes made in the app UI persist and are not reverted by
`darwin-switch`. To re-seed, delete the state file (or move it aside) and switch
again.

## CLI

Enable the Bitwarden CLI (official `bw` client):

```nix
aytordev.programs.terminal.tools.bitwarden-cli = {
  enable = true;
  client = "bw";            # or "rbw" (default)
  shellIntegration.enable = true;
  aliases.enable = true;
};
```

Key options:

- `client` — `"rbw"` (default) or `"bw"`.
- `server` — custom server URL (rbw only).
- `apiKey` — runtime API-key login: set `enable` plus `clientIdFile` /
  `clientSecretFile`. The generated `bitwarden-login-sops` helper uses a scoped
  pinentry adapter (rbw) or `bw login --apikey` (bw) and never exports tokens
  into the environment.
- `shellIntegration` — bash/zsh/fish session helpers that store `BW_SESSION`
  in a validated private directory.
- `aliases` — `bwl`, `bwu`, `bws`, `bwg`, `bwp`, `bwc`.

### Basic CLI usage

```bash
# Official client
bw-unlock            # unlock and store session
bw get password "GitHub"

# rbw client
rbw get github.com
```

## Security

- API keys are read from files at runtime; they are never placed in
  `home.sessionVariables`.
- Session keys live in a `0700` directory validated for ownership and
  permissions; see `checks/home-identity` for the enforced contract.
- Prefer file-based secrets (e.g. via the private `secrets` flake / sops) over
  plaintext in the config.

## Contributing

Follow `CONTRIBUTING.md` and the Module Contract V1 rules
(`docs/decisions/0008-module-contract-v1.md`). Update this README when module
options change.
