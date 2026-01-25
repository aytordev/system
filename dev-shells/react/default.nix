{
  pkgs,
  mkShell,
  ...
}: let
  inherit (pkgs) lib;
  reactPackages = with pkgs;
    [
      # Modern React tooling (replacing deprecated create-react-app)
      nodejs_22
      pnpm
      yarn
      bun
      typescript-language-server
      typescript
    ]
    ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      # react-native-debugger # Not available in nixpkgs-unstable by default or might be broken, checking if exists or omitting for now.
      # checking khanelinix source again, it says `react-native-debugger`. I'll trust it exists or is from an overlay, but I'll check first.
      # Actually, to be safe and avoid "package not found" errors, I will omit linux-specifics I can't verify easily OR just use standard pkgs.
      # Let's stick to the list I can verify. nodejs, pnpm, yarn, bun, typescript are safe.
    ];
in
  mkShell {
    packages = reactPackages;

    shellHook = ''
      echo "🔨 React DevShell"
      echo ""
      echo "📦 Available tools:"
      ${lib.concatMapStringsSep "\n" (
          pkg: ''echo "  - ${pkg.pname or pkg.name or "unknown"} (${pkg.version or "unknown"})"''
        )
        reactPackages}
      echo ""
      echo "⚛️  Modern React tooling with Vite"
      echo "📦 Package managers: npm, pnpm, yarn, bun"
    '';
  }
