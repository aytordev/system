final: prev: {
  ollama = prev.ollama.overrideAttrs (oldAttrs: rec {
    version = "0.11.4";
    
    # Use prebuilt binary for Darwin ARM64 to avoid compilation issues
    src = if prev.stdenv.isDarwin && prev.stdenv.isAarch64 then
      prev.fetchurl {
        url = "https://github.com/ollama/ollama/releases/download/v${version}/Ollama-darwin.zip";
        sha256 = "0d3865in9i209dmdzkk2nkqbsxzffdxlrqwm4wd2gdip98kb7229";
      }
    else
      oldAttrs.src;
    
    # Skip build phase for Darwin ARM64 binary
    dontBuild = prev.stdenv.isDarwin && prev.stdenv.isAarch64;
    
    # For Darwin ARM64, extract and install the binary
    installPhase = if prev.stdenv.isDarwin && prev.stdenv.isAarch64 then ''
      runHook preInstall
      
      unzip $src
      mkdir -p $out/bin
      cp Ollama.app/Contents/MacOS/ollama $out/bin/ollama || cp ollama $out/bin/ollama || true
      chmod +x $out/bin/ollama
      
      # Create completions
      mkdir -p $out/share/bash-completion/completions
      mkdir -p $out/share/fish/vendor_completions.d
      mkdir -p $out/share/zsh/site-functions
      
      $out/bin/ollama completion bash > $out/share/bash-completion/completions/ollama
      $out/bin/ollama completion fish > $out/share/fish/vendor_completions.d/ollama.fish
      $out/bin/ollama completion zsh > $out/share/zsh/site-functions/_ollama
      
      runHook postInstall
    '' else oldAttrs.installPhase;
    
    # Remove build dependencies for Darwin ARM64
    nativeBuildInputs = if prev.stdenv.isDarwin && prev.stdenv.isAarch64 then
      [ prev.makeWrapper prev.unzip ]
    else
      oldAttrs.nativeBuildInputs or [];
    
    buildInputs = if prev.stdenv.isDarwin && prev.stdenv.isAarch64 then
      []
    else
      oldAttrs.buildInputs or [];
  });
  
  # Alternative: Use ollama-bin package if available
  ollama-bin = prev.stdenv.mkDerivation rec {
    pname = "ollama-bin";
    version = "0.11.4";
    
    src = if prev.stdenv.isDarwin then
      prev.fetchurl {
        url = "https://github.com/ollama/ollama/releases/download/v${version}/Ollama-darwin.zip";
        sha256 = "0d3865in9i209dmdzkk2nkqbsxzffdxlrqwm4wd2gdip98kb7229";
      }
    else if prev.stdenv.isLinux && prev.stdenv.isAarch64 then
      prev.fetchurl {
        url = "https://github.com/ollama/ollama/releases/download/v${version}/ollama-linux-arm64.tgz";
        sha256 = "sha256-CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC="; # Replace with actual hash
      }
    else
      prev.fetchurl {
        url = "https://github.com/ollama/ollama/releases/download/v${version}/ollama-linux-amd64.tgz";
        sha256 = "sha256-DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD="; # Replace with actual hash
      };
    
    dontBuild = true;
    
    nativeBuildInputs = with prev; [ makeWrapper ] 
      ++ (if prev.stdenv.isDarwin then [ unzip ] else [ gnutar gzip ]);
    
    unpackPhase = if prev.stdenv.isDarwin then ''
      unzip $src
    '' else ''
      tar -xzf $src
    '';
    
    installPhase = ''
      runHook preInstall
      
      mkdir -p $out/bin
      if [ -d "Ollama.app" ]; then
        # macOS app bundle
        cp Ollama.app/Contents/MacOS/ollama $out/bin/ollama || cp Ollama.app/Contents/Resources/ollama $out/bin/ollama
      else
        # Linux binary
        cp ollama $out/bin/ollama || cp bin/ollama $out/bin/ollama
      fi
      chmod +x $out/bin/ollama
      
      # Wrap the binary to ensure it finds required libraries
      wrapProgram $out/bin/ollama \
        --prefix PATH : ${prev.lib.makeBinPath (with prev; [ ])}
      
      # Generate shell completions
      mkdir -p $out/share/bash-completion/completions
      mkdir -p $out/share/fish/vendor_completions.d
      mkdir -p $out/share/zsh/site-functions
      
      $out/bin/ollama completion bash > $out/share/bash-completion/completions/ollama || true
      $out/bin/ollama completion fish > $out/share/fish/vendor_completions.d/ollama.fish || true
      $out/bin/ollama completion zsh > $out/share/zsh/site-functions/_ollama || true
      
      runHook postInstall
    '';
    
    meta = with prev.lib; {
      description = "Get up and running with large language models locally";
      homepage = "https://ollama.ai";
      license = licenses.mit;
      platforms = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      mainProgram = "ollama";
    };
  };
}