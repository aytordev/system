{
  config,
  lib,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  cfg = config.aytordev.services.docker-socket;
in {
  options.aytordev.services.docker-socket = {
    enable = mkEnableOption "publication of the provider Docker socket at the standard path";

    socketPath = mkOption {
      type = types.str;
      default = "/var/run/docker.sock";
      description = "The path docker-aware tools hardcode; tools that use it do not read Docker contexts, so the provider socket is published here.";
    };

    targetPath = mkOption {
      type = types.str;
      description = ''
        Absolute path of the provider socket this adapter publishes. Required,
        with no default: a derived default would be user-relative (the provider
        keeps its socket under the user's configuration directory), which would
        force user identity during option evaluation — something the option
        docs generation does not guarantee.
      '';
    };
  };

  config = mkIf cfg.enable {
    # nix-darwin does NOT execute every `system.activationScripts.<name>`. Its
    # top-level activate script inlines a fixed allow-list of entry names
    # (`preActivation`, `checks`, `createRun`, `extraActivation`, `groups`,
    # `users`, `applications`, `pam`, `patches`, `openssh`, `etc`, `defaults`,
    # `userDefaults`, `launchd`, `userLaunchd`, `nix-daemon`, `time`,
    # `networking`, `power`, `keyboard`, `fonts`, `nvram`, `mas`, `homebrew`,
    # `postActivation`; see nix-darwin `modules/system/activation-scripts.nix`).
    # A custom entry name is still a valid option and even gets its own
    # derivation, but its text is never run: publishing this adapter as
    # `system.activationScripts.docker-socket` left the host silently without
    # /var/run/docker.sock until a functional host check found it missing.
    # `postActivation` is the documented user extension point and is in that
    # list. `mkAfter` is safe because the option is `types.lines`: concurrent
    # writers concatenate instead of clobbering.
    #
    # While the provider VM is stopped the symlink dangles. That is equivalent
    # to the socket not existing: a running VM is the precondition either way,
    # so nothing here tries to start or check the provider.
    #
    # Refusing to replace is the fail-closed action. Aborting the whole
    # activation with a non-zero exit would leave the machine half-configured,
    # so a foreign owner only produces a loud error and leaves the entry
    # untouched.
    system.activationScripts.postActivation.text = lib.mkAfter ''
      socketPath="${cfg.socketPath}"
      targetPath="${cfg.targetPath}"

      currentTarget=""
      if [ -L "$socketPath" ]; then
        currentTarget="$(/usr/bin/readlink "$socketPath")"
      fi

      if [ "$currentTarget" = "$targetPath" ]; then
        # Already ours (even if it currently dangles): idempotent no-op.
        :
      elif [ -L "$socketPath" ] || [ -e "$socketPath" ]; then
        /bin/echo "aytordev.services.docker-socket: refusing to replace $socketPath, which is owned by $(/usr/bin/readlink "$socketPath" 2>/dev/null || /bin/echo "a non-symlink entry (socket or regular file)"). Remove the existing entry or disable the competing provider; exactly one provider may own this socket."
      else
        /usr/bin/ln -sfn "$targetPath" "$socketPath"
      fi
    '';

    # Fail closed if the fragment ever stops reaching the script that actually
    # runs. The host was silently unconfigured once because a custom
    # activationScripts name is never executed; an evaluation error is the only
    # acceptable way to learn that again. `script` is absent only in synthetic
    # harnesses that stub the activation surface, so real nix-darwin
    # configurations always enforce this.
    assertions = [
      {
        assertion = let
          published = lib.attrByPath ["system" "activationScripts" "script" "text"] null config;
        in
          published
          == null
          || (lib.hasInfix cfg.socketPath published && lib.hasInfix cfg.targetPath published);
        message = "aytordev.services.docker-socket: the fragment is not present in system.activationScripts.script.text, which is the script nix-darwin actually runs. Do not publish this adapter through a custom activationScripts entry name; use one of the entries nix-darwin inlines, such as postActivation.";
      }
    ];
  };
}
