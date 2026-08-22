{
  inputs,
  self,
  ...
}: let
  reusableInputs = builtins.removeAttrs inputs ["secrets"];
in {
  flake.lib = {
    # keep-sorted start block=yes newline_separated=yes
    file = import ./file {
      inputs = reusableInputs;
      inherit self;
    };
    identity = import ./identity {};
    module = import ./module {inputs = reusableInputs;};
    overlay = import ./overlay {inputs = reusableInputs;};
    system = import ./system {inputs = reusableInputs;};
  };
}
