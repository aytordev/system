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

  cfg = config.aytordev.programs.desktop.logitech;

  # Logitech HID++ drivers are mutually exclusive at runtime: Logi Options+ and
  # OpenLogi both try to own the receiver, so only one can be active. Modeling
  # this as a single choice (instead of two independent booleans) means the
  # config can only ever declare one cask, and Homebrew's `cleanup =
  # "uninstall"` removes the previous one on switch.
  casks = {
    options-plus = "logi-options+";
    openlogi = "openlogi";
  };
in {
  options.aytordev.programs.desktop.logitech = {
    enable = mkEnableOption "Logitech device driver (Logi Options+ or OpenLogi)";

    driver = mkOption {
      type = types.enum [
        "options-plus"
        "openlogi"
      ];
      default = "options-plus";
      description = ''
        Which Logitech HID++ driver to install. Only one can be active at a
        time; switching uninstalls the previous cask through Homebrew cleanup.
        `options-plus` is the official Logitech app (full MX Master 4 support);
        `openlogi` is the local-first open-source alternative.
      '';
    };
  };

  config = mkIf cfg.enable {
    homebrew.casks = [casks.${cfg.driver}];
  };
}
