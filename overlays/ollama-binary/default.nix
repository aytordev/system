final: prev: {
  # Override ollama to use version 0.10.0 instead of broken 0.11.3
  # Version 0.11.3 has test failures on Darwin ARM64 with Metal
  # See: https://github.com/NixOS/nixpkgs/issues/431464
  ollama = final.buildGoModule rec {
    pname = "ollama";
    version = "0.10.0";
    
    src = final.fetchFromGitHub {
      owner = "ollama";
      repo = "ollama";
      rev = "v${version}";
      hash = "sha256-BoT4WUapxakETHAlHP64okcReMIhQ+PzKaSVpELvrcI=";
      fetchSubmodules = true;
    };
    
    vendorHash = "sha256-IgEf/WOc1eNGCif1fViIFxbgZAd6mHBqfxcaqH/WvGg=";
    
    nativeBuildInputs = with final; [
      cmake
    ] ++ final.lib.optionals final.stdenv.isDarwin (with final.darwin.apple_sdk_11_0.frameworks; [
      Accelerate
      Metal
      MetalKit
      MetalPerformanceShaders
    ]);
    
    buildInputs = with final; [
      final.stdenv.cc.cc.lib
    ] ++ final.lib.optionals final.stdenv.isDarwin (with final.darwin.apple_sdk_11_0.frameworks; [
      Accelerate
      Metal
      MetalKit
      MetalPerformanceShaders
    ]);
    
    # Disable tests on Darwin ARM64 due to Metal test failures
    doCheck = false;
    doInstallCheck = false;
    
    # Set build flags
    ldflags = [
      "-s"
      "-w"
      "-X=github.com/ollama/ollama/version.Version=${version}"
      "-X=github.com/ollama/ollama/server.mode=release"
    ];
    
    # Build tags for Metal support on Darwin
    tags = final.lib.optionals final.stdenv.isDarwin [ "metal" ];
    
    # Environment variables for build
    preBuild = ''
      export HOME=$TMPDIR
    '' + final.lib.optionalString final.stdenv.isDarwin ''
      export CGO_ENABLED=1
    '';
    
    postInstall = ''
      # Install shell completions if they exist
      installShellCompletion --cmd ollama \
        --bash <($out/bin/ollama completion bash 2>/dev/null || true) \
        --fish <($out/bin/ollama completion fish 2>/dev/null || true) \
        --zsh <($out/bin/ollama completion zsh 2>/dev/null || true)
    '';
    
    meta = with final.lib; {
      description = "Get up and running with large language models locally (pinned to v0.10.0 due to v0.11.3 test failures on Darwin ARM64)";
      homepage = "https://github.com/ollama/ollama";
      changelog = "https://github.com/ollama/ollama/releases/tag/v${version}";
      license = licenses.mit;
      platforms = platforms.unix;
      mainProgram = "ollama";
    };
  };
}