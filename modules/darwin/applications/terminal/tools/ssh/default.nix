{libraries, ...}: {
  imports = [
    (libraries.relativeToRoot "modules/shared/applications/terminal/tools/ssh")
  ];
}
