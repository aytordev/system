# Generated Pi theme and default selection, exercised only in synthetic homes.
{
  inputs,
  lib,
  pkgs,
  ...
}: let
  themePath = ".pi/agent/themes/aytordev.json";
  mkHome = enable:
    (inputs.self.lib.system.mkHome {
      system = pkgs.stdenv.hostPlatform.system;
      username = "pi-theme-ci";
      hostname = "pi-theme-ci";
      modules = [
        {
          aytordev.user = {
            enable = true;
            name = "pi-theme-ci";
            email = "pi-theme@example.test";
            fullName = "Pi Theme CI";
            home = "/tmp/pi-theme-ci";
          };
          home.stateVersion = "25.11";
          aytordev.theme = {
            name = "sora";
            variant = "dark";
          };
          aytordev.programs.terminal.tools.pi = {
            inherit enable;
            package = pkgs.writeShellScriptBin "pi" "exit 0";
          };
        }
      ];
    }).config;
  enabled = mkHome true;
  disabled = mkHome false;
  themeConfig = enabled.aytordev.theme;
  render = import ../../modules/home/programs/terminal/tools/pi/theme.nix;
  variants = lib.concatLists (lib.mapAttrsToList (family: provider:
    map (variant: {
      name = "${family}-${variant}";
      value = render {
        palette = provider.variants.${variant};
        isLight = variant == provider.lightVariant;
      };
    }) (builtins.attrNames provider.variants))
  themeConfig.providers);
  themeFiles = pkgs.writeText "pi-themes.json" (builtins.toJSON {
    active = builtins.fromJSON enabled.home.file.${themePath}.text;
    variants = builtins.listToAttrs variants;
  });
  activation = pkgs.writeText "pi-theme-activation.sh" (
    lib.replaceStrings [enabled.home.homeDirectory] ["$HOME"] enabled.home.activation.piThemeDefault.data
  );
in
  assert enabled.home.file ? ${themePath};
  assert !(enabled.home.file ? ".pi/agent/themes");
  assert !(enabled.home.file ? ".pi/agent/settings.json");
  assert !(disabled.home.file ? ${themePath});
  assert !(disabled.home.activation ? piThemeDefault);
    pkgs.runCommand "pi-theme" {
      nativeBuildInputs = [pkgs.python3 pkgs.bash];
    } ''
      export THEME_FILES=${themeFiles}
      export THEME_ACTIVATION=${activation}
      python3 - <<'PY'
      import json
      import os
      from pathlib import Path
      import re
      import subprocess
      import tempfile

      required = set("""
      accent border borderAccent borderMuted success error warning muted dim text
      thinkingText selectedBg userMessageBg userMessageText customMessageBg
      customMessageText customMessageLabel toolPendingBg toolSuccessBg toolErrorBg
      toolTitle toolOutput mdHeading mdLink mdLinkUrl mdCode mdCodeBlock
      mdCodeBlockBorder mdQuote mdQuoteBorder mdHr mdListBullet toolDiffAdded
      toolDiffRemoved toolDiffContext syntaxComment syntaxKeyword syntaxFunction
      syntaxVariable syntaxString syntaxNumber syntaxType syntaxOperator
      syntaxPunctuation thinkingOff thinkingMinimal thinkingLow thinkingMedium
      thinkingHigh thinkingXhigh bashMode scrollbarTrack scrollbarThumb
      searchMatchBg searchMatchText thinkingMax
      """.split())
      documents = json.loads(Path(os.environ["THEME_FILES"]).read_text())

      def resolve(theme, value, seen=()):
          if re.fullmatch(r"#[0-9a-fA-F]{6}", value):
              return value.lower()
          assert value not in seen, f"Cyclic theme reference: {value}"
          return resolve(theme, theme["vars"][value], seen + (value,))

      def color(theme, role):
          return resolve(theme, theme["colors"][role])

      def luminance(value):
          channels = [int(value[i:i+2], 16) / 255 for i in (1, 3, 5)]
          linear = [v / 12.92 if v <= 0.04045 else ((v + 0.055) / 1.055) ** 2.4 for v in channels]
          return sum(a * b for a, b in zip(linear, (0.2126, 0.7152, 0.0722)))

      for name, theme in {"active": documents["active"], **documents["variants"]}.items():
          assert theme["name"] == "aytordev"
          assert set(theme["colors"]) == required, name
          for value in [*theme["colors"].values(), *theme["export"].values()]:
              resolve(theme, value)
          for role in ("toolPendingBg", "toolSuccessBg", "toolErrorBg", "customMessageBg"):
              assert color(theme, role) == theme["vars"]["bgPanel"], (name, role)
          assert theme["appearance"] == ("light" if name.endswith(("lotus", "light")) else "dark")

      sora = documents["active"]
      assert sora == documents["variants"]["sora-dark"]
      assert color(sora, "accent") == "#80c8e0"
      assert color(sora, "toolSuccessBg") == "#14161e"
      assert color(sora, "selectedBg") == "#1e2430"
      assert color(sora, "success") == "#68a888"
      assert color(sora, "error") == "#c46c78"
      for foreground in ("text", "muted", "toolOutput", "userMessageText"):
          for background in ("toolSuccessBg", "toolErrorBg", "selectedBg", "userMessageBg", "searchMatchBg"):
              low, high = sorted((luminance(color(sora, foreground)), luminance(color(sora, background))))
              assert (high + 0.05) / (low + 0.05) >= 4.5, (foreground, background)

      with tempfile.TemporaryDirectory(prefix="pi theme ") as directory:
          home = Path(directory)
          settings = home / ".pi/agent/settings.json"
          activation = os.environ["THEME_ACTIVATION"]

          def activate(dry=False):
              environment = dict(os.environ, HOME=str(home), DRY_RUN_CMD="echo" if dry else "")
              result = subprocess.run(
                  ["bash", "-euc", 'source "$1"; printf "continued\\n"', "pi-theme-test", activation],
                  env=environment, text=True, capture_output=True,
              )
              assert result.returncode == 0, result.stderr
              assert result.stdout.endswith("continued\n"), result.stdout
              return result

          result = activate(dry=True)
          assert result.stderr == ""
          assert not (home / ".pi").exists(), "Dry run must not create files or directories"
          result = activate()
          assert (result.stdout, result.stderr) == ("continued\n", "")
          assert json.loads(settings.read_text()) == {"theme": "aytordev"}
          assert settings.stat().st_mode & 0o777 == 0o600

          original = {"packages": ["npm:gentle-pi@4.1.0"], "tuiMode": "fullscreen", "custom": {"keep": True}}
          settings.write_text(json.dumps(original))
          settings.chmod(0o640)
          result = activate()
          assert (result.stdout, result.stderr) == ("continued\n", "")
          assert json.loads(settings.read_text()) == {**original, "theme": "aytordev"}
          assert settings.stat().st_mode & 0o777 == 0o640
          before = (settings.read_bytes(), settings.stat().st_mtime_ns)
          result = activate()
          assert (result.stdout, result.stderr) == ("continued\n", "")
          assert (settings.read_bytes(), settings.stat().st_mtime_ns) == before

          for choice in ("Sora", "Gentleman-Cute", "system", None):
              settings.write_text(json.dumps({**original, "theme": choice}))
              before = (settings.read_bytes(), settings.stat().st_mtime_ns)
              result = activate()
              assert (result.stdout, result.stderr) == ("continued\n", "")
              assert (settings.read_bytes(), settings.stat().st_mtime_ns) == before

          settings.write_text(json.dumps(original))
          before = (settings.read_bytes(), settings.stat().st_mtime_ns)
          result = activate(dry=True)
          assert result.stderr == ""
          assert (settings.read_bytes(), settings.stat().st_mtime_ns) == before

          for invalid in ("{broken", "[]", "null"):
              settings.write_text(invalid)
              before = (settings.read_bytes(), settings.stat().st_mtime_ns, settings.stat().st_mode)
              result = activate()
              assert result.stdout == "continued\n"
              assert result.stderr == f"pi theme: {settings} is not a JSON object; leaving it untouched\n"
              assert (settings.read_bytes(), settings.stat().st_mtime_ns, settings.stat().st_mode) == before
              assert sorted(p.name for p in settings.parent.iterdir()) == ["settings.json"]

      print("PASS: Pi themes cover every family/variant; default activation preserves choices, settings and dry runs")
      PY
      touch "$out"
    ''
