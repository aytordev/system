{
  inputs,
  self,
  ...
}: {
  flake.lib = {
    # keep-sorted start block=yes newline_separated=yes
    file = import ./file {inherit inputs self;};
    module = import ./module {inherit inputs;};
    overlay = import ./overlay {inherit inputs;};
    system = import ./system {inherit inputs;};
  };
}
