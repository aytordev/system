final: prev: {
  # On Darwin, create a wrapper for Homebrew-installed Ollama
  # This allows us to use the Homebrew cask (which includes the full app)
  # while still managing configuration through Nix
  ollama = if prev.stdenv.isDarwin then
    prev.stdenv.mkDerivation rec {
      pname = "ollama";
      version = "0.11.4";
      
      # No source needed - we're wrapping the Homebrew installation
      dontUnpack = true;
      dontBuild = true;
      
      nativeBuildInputs = with prev; [ makeWrapper ];
      
      installPhase = ''
        runHook preInstall
        
        mkdir -p $out/bin
        
        # Create a wrapper script that uses the Homebrew-installed ollama
        makeWrapper /opt/homebrew/bin/ollama $out/bin/ollama \
          --prefix PATH : ${prev.lib.makeBinPath []} \
          --set-default OLLAMA_HOST "127.0.0.1:11434"
        
        # Try to generate completions from the Homebrew ollama
        mkdir -p $out/share/bash-completion/completions
        mkdir -p $out/share/fish/vendor_completions.d
        mkdir -p $out/share/zsh/site-functions
        
        if [ -x /opt/homebrew/bin/ollama ]; then
          /opt/homebrew/bin/ollama completion bash > $out/share/bash-completion/completions/ollama 2>/dev/null || true
          /opt/homebrew/bin/ollama completion fish > $out/share/fish/vendor_completions.d/ollama.fish 2>/dev/null || true
          /opt/homebrew/bin/ollama completion zsh > $out/share/zsh/site-functions/_ollama 2>/dev/null || true
        fi
        
        runHook postInstall
      '';
      
      meta = with prev.lib; {
        description = "Get up and running with large language models locally (Homebrew wrapper)";
        homepage = "https://ollama.ai";
        license = licenses.mit;
        platforms = [ "x86_64-darwin" "aarch64-darwin" ];
        mainProgram = "ollama";
      };
    }
  else
    prev.ollama; # Use original package for non-Darwin systems
}