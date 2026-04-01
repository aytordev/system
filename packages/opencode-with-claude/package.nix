{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs_22,
  ...
}:
buildNpmPackage rec {
  pname = "opencode-with-claude";
  version = "1.3.3";

  src = fetchFromGitHub {
    owner = "ianjwhite99";
    repo = "opencode-with-claude";
    rev = "v${version}";
    hash = "sha256-tRN9uB0NuIuMbcXgohksQ1JOp7BprbNS8m6sRS9pRpY=";
  };

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-w8IWO9CqBiNEqiPOUO7foNHQR7EwzhxiFFIu8B1NXYs=";

  nodejs = nodejs_22;

  meta = with lib; {
    description = "OpenCode plugin for Claude Max/Pro subscriptions via Meridian proxy";
    homepage = "https://github.com/ianjwhite99/opencode-with-claude";
    license = licenses.mit;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  };
}
