{
  lib,
  buildNpmPackage,
  nodejs_22,
}:
# Pi-owned MCP bridge (T07). The bridge code (index.ts, src/) is loaded by Pi's
# extension runtime (jiti); this derivation only pins the MCP client SDK and its
# transitive npm closure. The Home Manager module rewrites `servers.ts` with the
# selected catalog servers and assembles the deployed extension directory.
buildNpmPackage {
  pname = "pi-mcp-bridge";
  version = "0.1.0";
  src = ./.;

  nodejs = nodejs_22;

  # Exact dependency versions come from package-lock.json. The SDK is pinned to
  # 1.29.0 (see package.json) to match the version already present in the pinned
  # mcp-servers-nix closure.
  npmDepsHash = "sha256-8O9t/eXFYTRNiOND1r8V2fMzvChpNAYoV+Y7oq0UlcE=";

  # No compilation step: Pi's jiti loader runs the TypeScript directly.
  dontNpmBuild = true;

  meta = {
    description = "Pi extension that bridges selected MCP stdio servers into Pi tools";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
}
