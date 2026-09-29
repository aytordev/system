# Pure naming policy and helper factory; no dependency on module configuration.
{lib}: let
  forbidden = ["." ":"];
  fallbackName = "workspace";
  sanitizeName = name: let
    sanitized = lib.replaceStrings forbidden (map (_: "_") forbidden) name;
  in
    if sanitized == ""
    then fallbackName
    else sanitized;
  # Generate the runtime replacements from the same pure naming policy.
  sanitizeScript =
    lib.concatMapStringsSep "\n" (character: ''
      session_name="''${session_name//${character}/_}"
    '')
    forbidden;
  script = package: ''
    mode="''${1:-open}"
    session_name="$(basename "$(pwd)")"
    ${sanitizeScript}
    session_name="''${session_name:-${fallbackName}}"
    case "$mode" in
      new)
        exec ${lib.getExe package} new-session -s "$session_name" -c "$(pwd)"
        ;;
      attach)
        exec ${lib.getExe package} attach-session -t "=$session_name"
        ;;
      open)
        exec ${lib.getExe package} new-session -A -s "$session_name" -c "$(pwd)"
        ;;
      *)
        echo "usage: tmux-session [new|attach|open]" >&2
        exit 1
        ;;
    esac
  '';
in {
  inherit sanitizeName script;
  build = {
    pkgs,
    package,
  }:
    pkgs.writeShellApplication {
      name = "tmux-session";
      runtimeInputs = [pkgs.coreutils];
      text = script package;
    };
}
