{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  makeWrapper,
  nodejs_22,
  bun,
  ...
}:
buildNpmPackage rec {
  pname = "meridian";
  version = "1.22.1";

  src = fetchFromGitHub {
    owner = "rynfar";
    repo = "meridian";
    rev = "v${version}";
    hash = "sha256-Pul31v05x1rqRa6PV47rsq8F4pMUUMpM2RaUSybwBbM=";
  };

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-EIuMwExwd9Z9tP6VhGgjpZWwHqIygX9ipnpvK8P92q4=";

  nodejs = nodejs_22;
  nativeBuildInputs = [
    bun
    makeWrapper
  ];

  # claude-agent-sdk spawns `node cli.js` at runtime — needs node in PATH
  postInstall = ''
    wrapProgram $out/bin/meridian \
      --prefix PATH : "${nodejs_22}/bin"
    wrapProgram $out/bin/claude-max-proxy \
      --prefix PATH : "${nodejs_22}/bin"
  '';

  meta = with lib; {
    description = "Local Anthropic API proxy powered by Claude Max subscription";
    homepage = "https://github.com/rynfar/meridian";
    license = licenses.mit;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    mainProgram = "meridian";
  };
}
