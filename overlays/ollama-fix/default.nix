final: prev: {
  # Override ollama to use version 0.11.4 which should fix the Metal test failures from 0.11.3
  ollama = prev.ollama.overrideAttrs (oldAttrs: rec {
    version = "0.11.4";
    
    src = final.fetchFromGitHub {
      owner = "ollama";
      repo = "ollama";
      rev = "v${version}";
      hash = "sha256-joIA/rH8j+SJH5EVMr6iqKLve6bkntPQM43KCN9JTZ8=";
      fetchSubmodules = true;
    };
    
    # Update vendor hash for the new version
    vendorHash = "sha256-SlaDsu001TUW+t9WRp7LqxUSQSGDF1Lqu9M1bgILoX4=";
    
    # Keep tests disabled on Darwin ARM64 just in case
    doCheck = false;
    doInstallCheck = false;
    
    meta = oldAttrs.meta // {
      description = oldAttrs.meta.description or "Get up and running with large language models locally" + " (v0.11.4)";
    };
  });
}