# Re-export the shared SSH module with Darwin-specific configurations
{ libraries, ... }:

{
  imports = [
    (libraries.relativeToRoot "modules/shared/applications/terminal/tools/ssh")
  ];
}
