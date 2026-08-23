{
  cfg,
  configFile,
  lib,
  pkgs,
}: let
  secretExports = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (name: file: ''
      if [[ ! -r ${lib.escapeShellArg file} ]]; then
        printf 'LiteLLM secret file is not readable: %s\n' ${lib.escapeShellArg file} >&2
        exit 1
      fi
      export ${name}="$(<${lib.escapeShellArg file})"
    '')
    cfg.environmentFiles
  );
in
  pkgs.writeShellScriptBin "litellm-start" ''
    set -euo pipefail
    ${secretExports}
    exec ${lib.getExe cfg.package} \
      --config ${lib.escapeShellArg configFile} \
      --host ${lib.escapeShellArg cfg.host} \
      --port ${toString cfg.port} \
      "$@"
  ''
