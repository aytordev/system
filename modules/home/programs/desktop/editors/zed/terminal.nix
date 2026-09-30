# Pure selection; missing capabilities and package-less tmux use Zed's shell.
_: let
  resolve = {
    multiplexer ? "zellij",
    capabilities ? {},
  }: let
    capability = capabilities.${multiplexer} or {};
  in
    if multiplexer != "system" && (capability.enable or false) && (capability.package or null) != null
    then multiplexer
    else "system";
in {
  inherit resolve;
  shell = {
    multiplexer ? "zellij",
    capabilities ? {},
    helpers,
  }: let
    selected = resolve {inherit multiplexer capabilities;};
  in
    if selected == "system"
    then "system"
    else {program = helpers.${selected};};
}
