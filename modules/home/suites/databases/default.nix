{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkDefault mkIf;

  cfg = config.aytordev.suites.databases;

  # User-facing projection of the exact requested database clients. The source
  # packages are stock nixpkgs derivations; PostgreSQL and Redis ship no
  # client-only output, so the env links every upstream `bin` entry and prunes
  # everything except the requested clients (including the PostgreSQL and Redis
  # server commands). Source store paths can still carry full upstream server
  # binaries in the Nix store closure; only this projection reaches the user
  # profile.
  databaseClients = pkgs.buildEnv {
    name = "database-client-toolchain";
    paths = [
      pkgs.postgresql
      pkgs.mariadb.client
      pkgs.sqlite.bin
      pkgs.duckdb
      pkgs.redis
      pkgs.mongosh
    ];
    pathsToLink = ["/bin"];
    postBuild = ''
      keep="psql pg_dump pg_restore mysql mysqldump sqlite3 duckdb redis-cli mongosh"
      for file in "$out"/bin/*; do
        case " $keep " in
          *" $(basename "$file") "*) ;;
          *) rm "$file" ;;
        esac
      done
    '';
  };
in {
  options.aytordev.suites.databases = {
    enable = lib.mkEnableOption "database client tooling (SQL/NoSQL CLIs, rainfrog, DbGate)";
  };

  config = mkIf cfg.enable {
    # The CLI toolchain is owned by the suite so it stays installed
    # independently of the rainfrog (TUI) and DbGate (GUI) convenience flags.
    home.packages = [databaseClients];

    aytordev.programs = {
      terminal.tools.rainfrog.enable = mkDefault true;
      desktop.databases.dbgate.enable = mkDefault true;
    };
  };
}
