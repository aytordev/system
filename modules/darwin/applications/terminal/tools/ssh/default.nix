{ lib, ... }: {
  imports = [
    (lib.getFile "modules/shared/applications/terminal/tools/ssh")
  ];
}
