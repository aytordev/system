{pkgs}: let
  python = pkgs.python3.withPackages (ps: [ps.json5]);
in
  assert pkgs.python3Packages.json5.version == "0.13.0";
    pkgs.writeShellApplication {
      name = "zed-upstream";
      text = ''
        export PYTHONDONTWRITEBYTECODE=1
        export SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
        exec ${python}/bin/python3 -B ${./update.py} "$@"
      '';
      passthru = {inherit python;};
      meta.mainProgram = "zed-upstream";
    }
