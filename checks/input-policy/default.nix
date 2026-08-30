{
  inputs,
  pkgs,
  ...
}: let
  lock = builtins.fromJSON (builtins.readFile (inputs.self + "/flake.lock"));
  rootInputs = lock.nodes.${lock.root}.inputs;
  nixpkgsInputs = builtins.filter (name: builtins.match "nixpkgs.*" name != null) (
    builtins.attrNames rootInputs
  );
  independentNixpkgsInputs = ["secrets"];
  usesNixpkgs = name: let
    inputNode = rootInputs.${name};
  in
    (lock.nodes.${inputNode}.inputs or {}) ? nixpkgs;
  canonicalFollowers = builtins.filter (
    name: usesNixpkgs name && !builtins.elem name independentNixpkgsInputs
  ) (builtins.attrNames rootInputs);
  followsCanonical = name: let
    inputNode = rootInputs.${name};
  in
    (lock.nodes.${inputNode}.inputs.nixpkgs or null) == ["nixpkgs"];
  assertions = [
    (
      if nixpkgsInputs == ["nixpkgs"]
      then true
      else throw "root flake must expose exactly one nixpkgs lineage"
    )
    (
      if builtins.all followsCanonical canonicalFollowers
      then true
      else throw "root inputs must follow the canonical nixpkgs input"
    )
    (
      if builtins.all usesNixpkgs independentNixpkgsInputs
      then true
      else throw "declared independent inputs must provide their own nixpkgs"
    )
  ];
in
  builtins.deepSeq assertions (
    pkgs.runCommand "input-policy-check" {} ''
      touch "$out"
    ''
  )
