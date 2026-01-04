{
  config,
  lib,
  options,
  ...
}:
let
  inherit (lib.aytordev) mkOpt;
in
{
  options.aytordev.home = {
    file =
      mkOpt lib.types.attrs { }
        "A set of files to be managed by home-manager's <option>home.file</option>.";
    configFile =
      mkOpt lib.types.attrs { }
        "A set of files to be managed by home-manager's <option>xdg.configFile</option>.";
    extraOptions = mkOpt lib.types.attrs { } "Options to pass directly to home-manager.";
    homeConfig = mkOpt lib.types.attrs { } "Final config for home-manager.";
  };

  config = {
    aytordev.home.extraOptions = {
      home.file = lib.mkAliasDefinitions options.aytordev.home.file;
      xdg.enable = true;
      xdg.configFile = lib.mkAliasDefinitions options.aytordev.home.configFile;
    };

    home-manager.users.${config.aytordev.user.name} =
      lib.mkAliasDefinitions options.aytordev.home.extraOptions;

    home-manager = {
      # enables backing up existing files instead of erroring if conflicts exist
      backupFileExtension = "hm.old";

      useUserPackages = true;
      useGlobalPkgs = true;

      verbose = true;
    };
  };
}
