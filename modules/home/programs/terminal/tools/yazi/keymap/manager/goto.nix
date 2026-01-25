_: let
  mkGotoKeymap = {
    key,
    path,
    desc ? null,
    isCommand ? false,
  }: let
    defaultDesc =
      if isCommand
      then null
      else "Go to the ${path} directory";
    description =
      if desc != null
      then desc
      else defaultDesc;
    runCmd =
      if isCommand
      then path
      else "cd ${path}";
  in {
    on = [
      "g"
      key
    ];
    run = runCmd;
    desc = description;
  };
  gotoLocations = [
    {
      key = "D";
      path = "~/Downloads";
    }
    {
      key = "d";
      path = "~/Documents";
    }
    {
      key = "p";
      path = "~/Pictures";
    }
    {
      key = "r";
      path = ''shell -- ya emit cd "$(git rev-parse --show-toplevel)"'';
      isCommand = true;
      desc = "Go to the root of git directory";
    }
    {
      key = "w";
      path = "~/.local/share/wallpapers";
    }
  ];
in {
  prepend_keymap = map mkGotoKeymap gotoLocations;
}
