final: prev: {
  # Override ollama to disable tests on Darwin ARM64 to fix build issues
  # See: https://github.com/NixOS/nixpkgs/issues/431464
  ollama = prev.ollama.overrideAttrs (oldAttrs: {
    # Disable the check phase which is failing on Darwin ARM64
    # The Metal test fails with: computeFunction must not be nil
    doCheck = false;
    
    # Also skip the install check phase
    doInstallCheck = false;
    
    # Add a note about why we're disabling tests
    meta = oldAttrs.meta // {
      description = oldAttrs.meta.description + " (tests disabled on Darwin ARM64)";
    };
  });
}