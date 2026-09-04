{inputs}: let
  inherit (inputs.nixpkgs) lib;
  inherit
    (lib)
    mkOption
    types
    toUpper
    mkDefault
    mkForce
    ;
in rec {
  /**
  Resolve which aytordev shells are enabled and guard shell integration values.

  Upstream Home Manager programs.<tool>.*Integration options default to
  `home.shell.*` (true), so a tool would integrate into shells that are not
  even configured on the user. tie those integrations (and any tool that drops
  a Bash `conf.d` file) to `aytordev.programs.terminal.shells.enabledNames`.

  # Inputs

  `config`

  : 1\. Module config (the `config` argument of the importing module)

  # Returns

  `shellEnabled`

  : shell -> bool; whether the shell is enabled.

  `flags`

  : attrset with `enable{Bash,Fish,Zsh,Nushell}Integration` booleans, ready to
  merge into `programs.<tool>`.

  `whenShellEnabled`

  : shell -> value -> value; wraps a config value (e.g. `xdg.configFile`) with
  `lib.mkIf` so it only materializes when the shell is enabled.

  # Example

  ```nix
  let
    inherit (lib.aytordev) shellIntegration;
    si = shellIntegration config;
  in
    { programs.zoxide = { enable = true; options = ["--cmd cd"]; } // si.flags; }
  ```
  */
  shellIntegration = config: let
    enabledNames = config.aytordev.programs.terminal.shells.enabledNames or [];
    shellEnabled = shell: builtins.elem shell enabledNames;
  in {
    inherit shellEnabled;

    flags = {
      enableBashIntegration = shellEnabled "bash";
      enableFishIntegration = shellEnabled "fish";
      enableZshIntegration = shellEnabled "zsh";
      enableNushellIntegration = shellEnabled "nushell";
    };

    whenShellEnabled = shell: lib.mkIf (shellEnabled shell);
  };

  /**
  Enable a module with optional configuration.

  # Inputs

  `module`

  : 1\. Function argument

  `config`

  : 2\. Function argument
  */
  enable = module: moduleConfig:
    moduleConfig
    // {
      imports = [module] ++ (moduleConfig.imports or []);
    };

  /**
  Conditionally enable modules based on system.

  # Inputs

  `system`

  : 1\. Function argument

  `modules`

  : 2\. Function argument
  */
  enableForSystem = system: modules:
    builtins.filter (
      mod: mod.systems or [] == [] || builtins.elem system (mod.systems or [])
    )
    modules;

  /**
  Create a module with common options.

  # Inputs

  `name`

  : Module name

  `description`

  : Module description

  `options`

  : Module options

  `config`

  : Module configuration
  */
  mkModule = {
    name,
    description ? "",
    options ? {},
    config ? {},
  }: let
    moduleConfig = config;
  in
    {
      config,
      lib,
      ...
    }: {
      options.aytordev.${name} = lib.mkOption {
        type = lib.types.submodule {
          options =
            {
              enable = lib.mkEnableOption description;
            }
            // options;
        };
        default = {};
      };

      config = lib.mkIf config.aytordev.${name}.enable moduleConfig;
    };

  # Migrated aytordev utilities
  # Option creation helpers

  /**
  Create a nixpkgs option.

  # Inputs

  `type`

  : 1\. Function argument

  `default`

  : 2\. Function argument

  `description`

  : 3\. Function argument
  */
  mkOpt = type: default: description:
    mkOption {inherit type default description;};

  /**
  Create a nixpkgs option without a description.

  # Inputs

  `type`

  : 1\. Function argument

  `default`

  : 2\. Function argument
  */
  mkOpt' = type: default: mkOpt type default null;

  /**
  Create a boolean nixpkgs option.

  # Inputs

  `type`

  : 1\. Function argument

  `default`

  : 2\. Function argument

  `description`

  : 3\. Function argument
  */
  mkBoolOpt = mkOpt types.bool;

  /**
  Create a boolean nixpkgs option without a description.

  # Inputs

  `type`

  : 1\. Function argument

  `default`

  : 2\. Function argument
  */
  mkBoolOpt' = mkOpt' types.bool;

  /**
  Standard enabled pattern.
  */
  enabled = {
    enable = true;
  };

  /**
  Standard disabled pattern.
  */
  disabled = {
    enable = false;
  };

  /**
  Capitalize a string.

  # Inputs

  `s`

  : 1\. Function argument
  */
  capitalize = s: let
    len = lib.stringLength s;
  in
    if len == 0
    then ""
    else (toUpper (lib.substring 0 1 s)) + (lib.substring 1 len s);

  /**
  Convert a boolean to a number.

  # Inputs

  `bool`

  : 1\. Function argument
  */
  boolToNum = bool:
    if bool
    then 1
    else 0;

  /**
  Apply mkDefault to all attributes in a set.

  # Inputs

  `set`

  : 1\. Function argument
  */
  default-attrs = lib.mapAttrs (_key: mkDefault);

  /**
  Apply mkForce to all attributes in a set.

  # Inputs

  `set`

  : 1\. Function argument
  */
  force-attrs = lib.mapAttrs (_key: mkForce);

  /**
  Apply default-attrs to nested attribute sets.

  # Inputs

  `set`

  : 1\. Function argument
  */
  nested-default-attrs = lib.mapAttrs (_key: default-attrs);

  /**
  Apply force-attrs to nested attribute sets.

  # Inputs

  `set`

  : 1\. Function argument
  */
  nested-force-attrs = lib.mapAttrs (_key: force-attrs);
}
