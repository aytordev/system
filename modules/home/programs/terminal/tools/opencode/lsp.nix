# OpenCode LSP (Language Server Protocol) configuration module
# Defines language servers for different programming languages
{
  config,
  lib,
  pkgs,
  self,
  ...
}: let
  cfg = config.aytordev.programs.terminal.tools.opencode;
  userName = config.aytordev.user.name;
  hostName = config.aytordev.host.name;
  flakePath = toString self.outPath;
  homeConfiguration = "${userName}@${hostName}";
in {
  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = userName != null;
        message = "OpenCode LSP requires aytordev.user.name";
      }
      {
        assertion = hostName != null;
        message = "OpenCode LSP requires aytordev.host.name";
      }
    ];

    programs.opencode.settings.lsp = {
      nixd = {
        command = [(lib.getExe pkgs.nixd)];
        extensions = [".nix"];
        initialization = {
          formatting = {
            command = [(lib.getExe pkgs.nixfmt)];
          };
          options =
            {
              home-manager = {
                expr = "(builtins.getFlake \"${flakePath}\").homeConfigurations.\"${homeConfiguration}\".options";
              };
            }
            // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
              darwin = {
                expr = "(builtins.getFlake \"${flakePath}\").darwinConfigurations.\"${hostName}\".options";
              };
            };
        };
      };

      emmylua-ls = {
        command = [(lib.getExe pkgs.emmylua-ls)];
        extensions = [".lua"];
        initialization = {
          Lua = {
            diagnostics = {
              globals = [
                "vim"
                "Sbar"
                "spoon"
              ];
            };
            workspace = {
              library = [
                "/nix/store/*/share/lua/5.1"
                "/etc/profiles/per-user/${config.home.username}/share/lua/5.1"
              ];
            };
          };
        };
      };

      pyright = {
        command = [(lib.getExe pkgs.pyright)];
        extensions = [
          ".py"
          ".pyi"
        ];
      };

      bashls = {
        command = [
          (lib.getExe pkgs.bash-language-server)
          "start"
        ];
        extensions = [
          ".sh"
          ".bash"
        ];
      };

      clangd = {
        command = [(lib.getExe' pkgs.clang-tools "clangd")];
        extensions = [
          ".c"
          ".cpp"
          ".cc"
          ".cxx"
          ".c++"
          ".h"
          ".hpp"
          ".hh"
          ".hxx"
          ".h++"
        ];
      };

      typescript = {
        command = [
          (lib.getExe pkgs.typescript-language-server)
          "--stdio"
        ];
        extensions = [
          ".ts"
          ".tsx"
          ".js"
          ".jsx"
          ".mjs"
          ".cjs"
          ".mts"
          ".cts"
        ];
      };

      gopls = {
        command = [(lib.getExe pkgs.gopls)];
        extensions = [
          ".go"
          ".mod"
          ".sum"
        ];
      };

      rust-analyzer = {
        command = [(lib.getExe pkgs.rust-analyzer)];
        extensions = [".rs"];
      };

      # FIXME: roslyn-ls broken due to Swift build failure in nixpkgs
      # csharp = {
      #   command = [(lib.getExe pkgs.roslyn-ls)];
      #   extensions = [
      #     ".cs"
      #     ".csx"
      #     ".cake"
      #   ];
      # };

      yamlls = {
        command = [
          (lib.getExe pkgs.yaml-language-server)
          "--stdio"
        ];
        extensions = [
          ".yaml"
          ".yml"
        ];
      };

      jsonls = {
        command = [
          (lib.getExe' pkgs.vscode-langservers-extracted "vscode-json-language-server")
          "--stdio"
        ];
        extensions = [
          ".json"
          ".jsonc"
        ];
      };

      taplo = {
        command = [
          (lib.getExe pkgs.taplo)
          "lsp"
          "stdio"
        ];
        extensions = [".toml"];
      };
    };
  };
}
