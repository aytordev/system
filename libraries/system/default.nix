{inputs, ...}: {
  # System configuration builders
  mkDarwin = import ./mk-darwin {inherit inputs;};
  mkSystem = import ./mk-system {inherit inputs;};
  mkHome = import ./mk-home {inherit inputs;};

  # Common utilities used by system builders
  common = import ./common {inherit inputs;};
}
