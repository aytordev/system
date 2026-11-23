{
  self,
  inputs,
  ...
}: {
  perSystem = {
    pkgs,
    config,
    lib,
    ...
  }: let
    # Define common packages that should be in all shells
    commonPackages = with pkgs; [
      git
      git-lfs
      gh
      nixpkgs-fmt
      statix
      deadnix
      jq
      yq-go
      htop
      file
      tree
    ];

    # Path to the dev-shells directory
    shellsPath = ../../../dev-shells;

    # Filter for directories that contain a default.nix
    isShellDir = name: type:
      type == "directory" && builtins.pathExists (shellsPath + "/${name}/default.nix");

    # Get list of valid shell directories
    shellDirs = lib.filterAttrs isShellDir (builtins.readDir shellsPath);
    shellNames = lib.attrNames shellDirs;

    # Shell names allowed to install the consumer checkout's Git hooks on entry
    # (pre-commit). The policy is enforced centrally by name on purpose: no
    # shell file opts in or out, and every other shell — including all reusable
    # language shells — leaves the consumer project's hooks untouched.
    gitHookShellNames = ["nix"];

    # Fail-safe for hook-installing shells: a checkout that already carries any
    # Git hook (a real Git hook-name file, executable or not) or custom
    # hook routing (core.hooksPath pointing away from the default directory)
    # must be left exactly as the user set it — running the installer would
    # rewrite their core.hooksPath and overwrite or disable their hooks (the
    # upstream script deletes managed hooks such as an existing pre-push).
    # Only a clean checkout gets the installation script. The
    # `# >>> aytordev-hook-guard` markers delimit the function for the automated
    # extraction in `checks/dev-shell-hook-contract`.
    gitHookGuard = ''
      # >>> aytordev-hook-guard
      aytordev_should_install_git_hooks() {
        local configuredHooksPath defaultHooksDir existingHook hooksDir
        configuredHooksPath="$(git config --get core.hooksPath 2>/dev/null || true)"
        defaultHooksDir="$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null || true)/hooks"
        hooksDir="$(git rev-parse --path-format=absolute --git-path hooks 2>/dev/null || true)"
        if [ -z "$hooksDir" ] || { [ -e "$hooksDir" ] && [ ! -d "$hooksDir" ]; } || [ -L "$hooksDir" ]; then
          echo "dev-shell: no Git hooks directory; skipping Git hook installation" >&2
          return 1
        fi
        if [ -n "$configuredHooksPath" ] && [ "$hooksDir" != "$defaultHooksDir" ]; then
          echo "dev-shell: core.hooksPath is set to '$configuredHooksPath'; leaving custom hook routing untouched, skipping Git hook installation" >&2
          return 1
        fi
        existingHook=""
        if [ -d "$hooksDir" ]; then
          ls -A "$hooksDir" >/dev/null 2>&1 || return 1
          local hookName hookList
          hookList="applypatch-msg pre-applypatch post-applypatch pre-commit pre-merge-commit
            prepare-commit-msg commit-msg post-commit pre-rebase post-checkout post-merge pre-push
            pre-receive update proc-receive post-receive post-update reference-transaction
            push-to-checkout pre-auto-gc post-rewrite sendemail-validate fsmonitor-watchman
            p4-changelist p4-prepare-changelist p4-post-changelist p4-pre-submit post-index-change"
          for hookName in $hookList; do
            if [ -e "$hooksDir/$hookName" ] || [ -L "$hooksDir/$hookName" ]; then
              existingHook="$hookName"
              break
            fi
          done
        fi
        if [ -n "$existingHook" ]; then
          echo "dev-shell: existing Git hook '$existingHook' found; leaving hooks untouched, skipping Git hook installation" >&2
          return 1
        fi
        return 0
      }
      # <<< aytordev-hook-guard
    '';

    # Custom mkShell wrapper that injects common packages and, only for the
    # shells named in `gitHookShellNames`, the pre-commit install script.
    # NOTE: pkgs.pre-commit (Python) is Linux-only because nixpkgs' pre-commit
    # has dotnet-sdk in nativeCheckInputs, which requires Swift to build.
    # git-hooks-nix's installationScript does NOT depend on pkgs.pre-commit —
    # it generates bash hooks that call tools directly, so it works on Darwin.
    mkShell = name: shellAttrs:
      pkgs.mkShell (shellAttrs
        // {
          nativeBuildInputs =
            (shellAttrs.nativeBuildInputs or [])
            ++ commonPackages
            ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [pkgs.pre-commit];
          packages = shellAttrs.packages or [];
          shellHook =
            (shellAttrs.shellHook or "")
            + lib.optionalString
            (lib.elem name gitHookShellNames)
            (lib.concatStringsSep "\n" [
              ""
              gitHookGuard
              "if aytordev_should_install_git_hooks; then"
              config.pre-commit.installationScript
              "fi"
            ]);
        });

    # Function to import and build a single shell
    buildShell = name: _: {
      ${name} = import (shellsPath + "/${name}/default.nix") {
        inherit pkgs shellNames;
        inherit (self) inputs;
        mkShell = mkShell name;
      };
    };
  in {
    devShells = lib.foldl (acc: name: acc // buildShell name null) {} shellNames;
  };
}
