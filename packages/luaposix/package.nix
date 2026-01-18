{
  pkgs,
  ...
}:
pkgs.lua54Packages.buildLuarocksPackage {
  pname = "luaposix";
  version = "36.2.1";

  # Use git source to avoid src.rock directory structure issues
  src = pkgs.fetchFromGitHub {
    owner = "luaposix";
    repo = "luaposix";
    rev = "v36.2.1";
    hash = "sha256-oxHH7RmaEGLU1tSlFhtf7F6CKOSRaNamq7QxtWyfwtI=";
  };

  knownRockspec = (pkgs.fetchurl {
    url = "https://luarocks.org/manifests/gvvaughan/luaposix-36.2.1-1.rockspec";
    hash = "sha256-mlv8WUAdD+pfMUXGVh3zGgknfMoKDzFcyoeOyEtJj1Y=";
  }).outPath;

  # Fix rockspec to assume we are at root
  preBuild = ''
    # The rockspec expects to be able to run build-aux/luke
    # Check if we are in the right directory
    ls -la
  '';

  disabled = false;
}
