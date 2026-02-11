_final: prev: {
  # Overlay for Google Chrome Stable, always using the "latest" version.
  #
  # IMPORTANT:
  # - The sha256 hash must be updated every time Google updates the .dmg.
  # - To get the correct hash, run:
  #     nix-prefetch-url https://dl.google.com/chrome/mac/stable/googlechrome.dmg
  #   and replace the sha256 value below.
  # - If the hash is incorrect, Nix will show you the expected one during the build.
  #
  # This overlay installs the app in $out/Applications.

  google-chrome = prev.stdenv.mkDerivation rec {
    pname = "google-chrome";
    version = "latest";

    src = prev.fetchurl {
      url = "https://dl.google.com/chrome/mac/stable/googlechrome.dmg";
      sha256 = "sha256-7xgcc1oCRq7Iak8y41IeAvBYockf5HtFvQV69QTdXKM=";
    };

    nativeBuildInputs = [prev.undmg];

    sourceRoot = "Google Chrome.app";

    installPhase = ''
      mkdir -p $out/Applications
      cp -r . $out/Applications/Google\ Chrome.app
    '';

    meta = with prev.lib; {
      description = "Google Chrome for macOS (latest)";
      homepage = "https://www.google.com/chrome/";
      platforms = ["aarch64-darwin" "x86_64-darwin"];
      license = licenses.unfree;
    };
  };
}
