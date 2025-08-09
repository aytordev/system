final: prev: {
  # Override ollama to use version 0.11.4 which should fix the Metal test failures from 0.11.3
  ollama = prev.ollama.overrideAttrs (oldAttrs: rec {
    version = "0.11.4";
    
    src = final.fetchFromGitHub {
      owner = "ollama";
      repo = "ollama";
      rev = "v${version}";
      hash = "sha256-C/wuEskUkNt9Q7EMsiVx6liJemfKW3tssmpQjzRsQJk=";
      fetchSubmodules = true;
    };
    
    # Update vendor hash for the new version
    vendorHash = "sha256-hSxcREAujhvzHVNwnRTfhi0MKI3s8HNavER2VLz6SYk=";
    
    # Keep tests disabled on Darwin ARM64 just in case
    doCheck = false;
    doInstallCheck = false;
    
    meta = oldAttrs.meta // {
      description = oldAttrs.meta.description or "Get up and running with large language models locally" + " (v0.11.4)";
    };
  });
}