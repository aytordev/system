{
  lib,
  stdenvNoCC,
  fetchurl,
  undmg,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "pencil-dev";
  version = "1.1.63";

  src = fetchurl {
    url = "https://www.pencil.dev/download/Pencil-mac-arm64.dmg";
    hash = "sha256-YhYGgnzZtZbBBqCHkABkE/dAcQbMLo/sS4RcHg+JtdA=";
  };

  nativeBuildInputs = [undmg];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/Applications"
    cp -r "Pencil.app" "$out/Applications/"
    runHook postInstall
  '';

  meta = {
    description = "Design on canvas. Land in code.";
    homepage = "https://pencil.dev";
    platforms = ["aarch64-darwin"];
    license = lib.licenses.unfree;
  };
}
