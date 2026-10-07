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
    # Named activation script, matching the `system.activationScripts.rosetta`
    # precedent: it owns a single privileged concern and stays idempotent.
    #
    # While the provider VM is stopped the symlink dangles. That is equivalent
    # to the socket not existing: a running VM is the precondition either way,
    # so nothing here tries to start or check the provider.
    #
    # Refusing to replace is the fail-closed action. Aborting the whole
    # activation with a non-zero exit would leave the machine half-configured,
    # so a foreign owner only produces a loud error and leaves the entry
    # untouched.
    system.activationScripts.docker-socket.text = ''
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
  };
}
