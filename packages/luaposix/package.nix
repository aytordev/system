{pkgs, ...}: let
  # luaposix 36.2.1 rockspec declares "lua >= 5.1, < 5.5" but the code is
  # compatible with 5.5. Patch the upper bound before luarocks processes it.
  patchedRockspec = pkgs.runCommand "luaposix-36.2.1-1.rockspec" {} ''
    sed 's/lua >= 5.1, < 5.5/lua >= 5.1/' ${
      pkgs.fetchurl {
        url = "https://luarocks.org/manifests/gvvaughan/luaposix-36.2.1-1.rockspec";
        hash = "sha256-mlv8WUAdD+pfMUXGVh3zGgknfMoKDzFcyoeOyEtJj1Y=";
      }
    } > $out
  '';
in
  pkgs.lua55Packages.buildLuarocksPackage {
    pname = "luaposix";
    version = "36.2.1";

    src = pkgs.fetchFromGitHub {
      owner = "luaposix";
      repo = "luaposix";
      rev = "v36.2.1";
      hash = "sha256-oxHH7RmaEGLU1tSlFhtf7F6CKOSRaNamq7QxtWyfwtI=";
    };

    knownRockspec = patchedRockspec.outPath;

    disabled = false;
  }
