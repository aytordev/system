{ lib, ... }: {
  imports = [
    (lib.getFile "modules/common/applications/terminal/tools/ssh")
  ];
}
