{
  config,
  lib,
  osConfig ? {},
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkDefault;
  inherit (lib.aytordev) enabled;

  # TODO: Requires home-manager sops.age.keyFile configuration
  # See NOTE below sops.secrets for details on how to enable.
  tokenExports = "";
  # tokenExports = lib.optionalString (osConfig.aytordev.security.sops.enable or false) /* Bash */ ''
  #   if [ -f ${config.sops.secrets.ANTHROPIC_API_KEY.path} ]; then
  #     ANTHROPIC_API_KEY="$(cat ${config.sops.secrets.ANTHROPIC_API_KEY.path})"
  #     export ANTHROPIC_API_KEY
  #   fi
  #   if [ -f ${config.sops.secrets.GEMINI_API_KEY.path} ]; then
  #     GEMINI_API_KEY="$(cat ${config.sops.secrets.GEMINI_API_KEY.path})"
  #     export GEMINI_API_KEY
  #   fi
  #   if [ -f ${config.sops.secrets.OPENAI_API_KEY.path} ]; then
  #     OPENAI_API_KEY="$(cat ${config.sops.secrets.OPENAI_API_KEY.path})"
  #     export OPENAI_API_KEY
  #   fi
  # '';

  cfg = config.aytordev.suites.development;
  isWSL = osConfig.aytordev.archetypes.wsl.enable or false;

  # Bash-specific aliases (uses bash syntax like $(), f(){}, $VAR)
  bashAliases = {
    # Nixpkgs
    prefetch-sri = "nix store prefetch-file $1";
    nra = ''nixpkgs-review pr $1 --systems "aarch64-darwin x86_64-linux aarch64-linux"'';
    nrap = ''nixpkgs-review pr $1 --systems "aarch64-darwin x86_64-linux aarch64-linux" --post-result --num-parallel-evals 3'';
    nrapa = ''nixpkgs-review pr $1 --systems "aarch64-darwin x86_64-linux aarch64-linux" --post-result --num-parallel-evals 3 --approve-pr'';
    nrd = ''nixpkgs-review pr $1 --systems "aarch64-darwin"'';
    nrdp = ''nixpkgs-review pr $1 --systems "aarch64-darwin" --post-result'';
    nrl = ''nixpkgs-review pr $1 --systems "x86_64-linux aarch64-linux" --num-parallel-evals 2'';
    nrlp = ''nixpkgs-review pr $1 --systems "x86_64-linux aarch64-linux" --num-parallel-evals 2 --post-result'';
    nup = ''nix-update --commit -u $1'';
    num = ''nix-shell maintainers/scripts/update.nix --argstr maintainer $1'';
    ncs = ''f(){ nix build "nixpkgs#$1" --no-link; nix path-info --recursive --closure-size --human-readable $(nix-build --no-out-link '<nixpkgs>' -A "$1"); }; f'';
    ncsnc = ''f(){ nix build ".#nixosConfigurations.$1.config.system.build.toplevel" --no-link; nix path-info --recursive --closure-size --human-readable $(nix eval --raw ".#nixosConfigurations.$1.config.system.build.toplevel.outPath"); }; f'';
    ncsdc = ''f(){ nix build ".#darwinConfigurations.$1.config.system.build.toplevel" --no-link; nix path-info --recursive --closure-size --human-readable $(nix eval --raw ".#darwinConfigurations.$1.config.system.build.toplevel.outPath"); }; f'';
    vim-update-all = ''nix run nixpkgs#vimPluginsUpdater -- --github-token=$(echo $GITHUB_TOKEN)'';
    tree-update-all = ''./pkgs/applications/editors/vim/plugins/utils/nvim-treesitter/update.py; git add ./pkgs/applications/editors/vim/plugins/nvim-treesitter/generated.nix; git commit -m "vimPlugins.nvim-treesitter: update grammars"'';
    lua-update-all = ''nix run nixpkgs#luarocks-packages-updater -- --github-token=$(echo $GITHUB_TOKEN)'';
    yazi-update = ''f(){ ./pkgs/by-name/ya/yazi/plugins/update.py --plugin $1 --commit }; f'';
    yazi-update-all = ''./pkgs/by-name/ya/yazi/plugins/update.py --all --commit'';
    # Home-Manager
    hmd = ''nix build -L .#docs-html; ${
        if pkgs.stdenv.hostPlatform.isDarwin
        then "open"
        else "xdg-open"
      } result/share/doc/home-manager/index.xhtml'';
    hmt = ''f(){ nix-build -j auto --show-trace --pure --option allow-import-from-derivation false tests -A build."$1"; }; f'';
    hmtf = ''f(){ nix build -L --option allow-import-from-derivation false --reference-lock-file flake.lock "./tests#test-$1"; }; f'';
    hmts = ''f(){ nix build -L --option allow-import-from-derivation false --reference-lock-file flake.lock "./tests#test-$1"; nix path-info -rSh ./result; }; f'';
  };
in {
  options.aytordev.suites.development = {
    enable = lib.mkEnableOption "common development configuration";
    azureEnable = lib.mkEnableOption "azure development configuration";
    dockerEnable = lib.mkEnableOption "docker development configuration";
    gameEnable = lib.mkEnableOption "game development configuration";
    goEnable = lib.mkEnableOption "go development configuration";
    kubernetesEnable = lib.mkEnableOption "kubernetes development configuration";
    nixEnable = lib.mkEnableOption "nix development configuration";
    sqlEnable = lib.mkEnableOption "sql development configuration";
    aiEnable = lib.mkEnableOption "ai development configuration";
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs;
        [
          jqp
          onefetch
          tree-sitter
          # NOTE: when web ui needed. not cached upstream though
          # (tree-sitter.override {
          #   webUISupport = true;
          # })
        ]
        ++ lib.optionals (!isWSL) [
          bruno
        ]
        ++ lib.optionals cfg.dockerEnable [
          podman
          podman-tui
        ]
        ++ lib.optionals cfg.nixEnable [
          hydra-check
          nix-bisect
          nix-diff
          nix-fast-build
          nix-health
          nix-index
          nix-output-monitor
          nix-update
          nixpkgs-hammering
          nixpkgs-lint-community
          nixpkgs-review
          nurl
        ];

      # Only shell-agnostic aliases in home.shellAliases (applies to all shells including Nushell)
      shellAliases = {
        # Simple aliases that work across all shells
        nrh = ''nixpkgs-review rev HEAD'';
        vim-add = ''nix run nixpkgs#vimPluginsUpdater add'';
        vim-update = ''nix run nixpkgs#vimPluginsUpdater update'';
        tree-check = ''nix build .#vimPlugins.nvim-treesitter.passthru.tests.check-queries'';
        hmt-repl = ''nix repl --reference-lock-file flake.lock ./tests'';
      };
    };

    programs = {
      bash = {
        initExtra = tokenExports;
        shellAliases = bashAliases;
      };
      fish.shellInit = tokenExports;
      nix-your-shell = mkDefault enabled;
      zsh = {
        initContent = tokenExports;
        shellAliases = bashAliases;
      };
    };

    aytordev = {
      programs = {
        desktop = {
          editors = {
            antigravity = mkDefault enabled;
            vscode.enable = mkDefault (!isWSL);
            zed = mkDefault enabled;
          };
        };

        terminal = {
          # TODO: Add terminal.editors when neovim module exists
          # helix = enabled;
          # neovim = { enable = true; default = true; };

          tools = {
            act = mkDefault enabled;
            # azure.enable = cfg.azureEnable;  # TODO: module doesn't exist
            # AI tools - use mkDefault so home config can override
            agentapi.enable = mkDefault cfg.aiEnable;
            aider.enable = mkDefault cfg.aiEnable;
            claude-code.enable = mkDefault cfg.aiEnable;
            engram.enable = mkDefault cfg.aiEnable;
            gemini-cli.enable = mkDefault cfg.aiEnable;
            litellm.enable = mkDefault cfg.aiEnable;
            mcp.enable = mkDefault cfg.aiEnable;
            ollama.enable = mkDefault cfg.aiEnable;
            opencode.enable = mkDefault cfg.aiEnable;
            git-crypt = mkDefault enabled;
            # go.enable = cfg.goEnable;  # TODO: module doesn't exist
            gh = mkDefault enabled;
            jujutsu = mkDefault enabled;
            jjui = mkDefault enabled;
            k9s.enable = mkDefault cfg.kubernetesEnable;
            lazydocker.enable = mkDefault cfg.dockerEnable;
            lazygit = mkDefault enabled;
            # oh-my-posh = mkDefault enabled;  # TODO: module doesn't exist
          };
        };
      };

      # Ollama service managed separately:
      # - macOS: darwin module (aytordev.services.ollama) via darwin dev suite
      # - Linux: home-manager systemd service (ollama.service.enable)
    };

    # NOTE: Home-Manager Sops Configuration Required
    #
    # This sops.secrets block uses the home-manager sops-nix module, which is
    # SEPARATE from the darwin sops module. Even if darwin's sops.age.keyFile
    # is configured, home-manager needs its own configuration.
    #
    # To enable this suite, add to your home config:
    #
    #   sops.age.keyFile = "/Users/${username}/.config/sops/age/keys.txt";
    #
    # Or alternatively, move these secrets to the darwin sops module at:
    #   systems/<arch>/<hostname>/default.nix → aytordev.security.sops.secrets
    #
    # sops.secrets = lib.mkIf (osConfig.aytordev.security.sops.enable or false) {
    #   ANTHROPIC_API_KEY = {
    #     sopsFile = lib.getFile "secrets/CORE/default.yaml";
    #     path = "${config.home.homeDirectory}/.ANTHROPIC_API_KEY";
    #   };
    #   AZURE_OPENAI_API_KEY = {
    #     sopsFile = lib.getFile "secrets/CORE/default.yaml";
    #     path = "${config.home.homeDirectory}/.AZURE_OPENAI_API_KEY";
    #   };
    #   GEMINI_API_KEY = {
    #     sopsFile = lib.getFile "secrets/aytordev/default.yaml";
    #     path = "${config.home.homeDirectory}/.GEMINI_API_KEY";
    #   };
    #   OPENAI_API_KEY = {
    #     sopsFile = lib.getFile "secrets/CORE/default.yaml";
    #     path = "${config.home.homeDirectory}/.OPENAI_API_KEY";
    #   };
    #   TAVILY_API_KEY = {
    #     sopsFile = lib.getFile "secrets/aytordev/default.yaml";
    #     path = "${config.home.homeDirectory}/.TAVILY_API_KEY";
    #   };
    # };
  };
}
