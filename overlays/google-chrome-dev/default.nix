final: prev: {
  # Overlay for Google Chrome Dev, always using the "latest" version.
  #
  # IMPORTANT:
  # - The sha256 hash must be updated every time Google updates the .dmg.
  # - To get the correct hash, run:
  #     nix-prefetch-url https://dl.google.com/chrome/mac/dev/googlechromedev.dmg
  #   and replace the sha256 value below.
  # - If the hash is incorrect, Nix will show you the expected one during the build.
  #
  # This overlay installs the app in $out/programs.
  # If you want it to appear in /programs, create a symlink manually.

  google-chrome-dev = prev.stdenv.mkDerivation rec {
    pname = "google-chrome-dev";
    version = "latest";

    src = prev.fetchurl {
      url = "https://dl.google.com/chrome/mac/dev/googlechromedev.dmg";
      sha256 = "sha256-fQt65ml8GmhPhn58C8hcnMJvHEAM7TFJoFxEwQSMimQ=";
    };

    nativeBuildInputs = [prev.undmg];

    sourceRoot = "Google Chrome Dev.app";

    installPhase = ''
      mkdir -p $out/programs
      cp -r . $out/programs/Google\ Chrome\ Dev.app
    '';

    meta = with prev.lib; {
      description = "Google Chrome Dev for macOS (latest)";
      homepage = "https://www.google.com/chrome/dev/";
      platforms = ["aarch64-darwin" "x86_64-darwin"];
      license = licenses.unfree;
    };
  };
}
