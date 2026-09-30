# Pure helper factory shared by the capability and terminal consumers.
{lib}: let
  script = package: ''
    mode="''${1:-open}"
    session_name="$(basename "$(pwd)")"
    case "$mode" in
      new)
        exec ${lib.getExe package} -s "$session_name" options --default-cwd "$(pwd)"
        ;;
      attach)
        exec ${lib.getExe package} a "$session_name"
        ;;
      open)
        exec ${lib.getExe package} attach --create "$session_name" options --default-cwd "$(pwd)"
        ;;
      *)
        echo "usage: zellij-session [new|attach|open]" >&2
        exit 1
        ;;
    esac
  '';
in {
  inherit script;
  build = {
    pkgs,
    package,
  }:
    pkgs.writeShellApplication {
      name = "zellij-session";
      runtimeInputs = [pkgs.coreutils];
      text = script package;
    };
}
