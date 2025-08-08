{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.applications.desktop.browsers.firefox-dev;
in {
  options.applications.desktop.browsers.firefox-dev = {
    enable = mkEnableOption "Whether or not to enable Firefox Developer Edition";
  };

  config = mkIf cfg.enable {
    # Install Firefox Developer Edition as a standalone package
    # This avoids conflicts with the regular Firefox configuration
    home.packages = [
      pkgs.firefox-devedition
    ];

    # Firefox Developer Edition is installed as a regular macOS application
    # It will appear in Applications folder and Launchpad automatically

    # Create a helper script for easy developer profile creation
    home.file.".local/bin/firefox-dev-setup" = {
      text = ''
        #!/usr/bin/env bash
        # Firefox Developer Edition Setup Script
        # This script helps configure Firefox Developer Edition for development

        echo "Firefox Developer Edition Setup"
        echo "================================"
        echo ""
        echo "To configure Firefox Developer Edition for development:"
        echo ""
        echo "1. Launch Firefox Developer Edition"
        echo "2. Go to about:config"
        echo "3. Set the following preferences for development:"
        echo ""
        echo "   Developer Tools:"
        echo "   - devtools.chrome.enabled = true"
        echo "   - devtools.debugger.remote-enabled = true"
        echo "   - devtools.theme = dark"
        echo "   - devtools.toolbox.host = right"
        echo "   - devtools.webconsole.timestampMessages = true"
        echo "   - devtools.webconsole.persistlog = true"
        echo "   - devtools.netmonitor.persistlog = true"
        echo "   - devtools.cache.disabled = true"
        echo ""
        echo "   Performance:"
        echo "   - browser.cache.disk.enable = false"
        echo "   - browser.cache.memory.enable = true"
        echo "   - network.http.use-cache = false"
        echo ""
        echo "   Security (relaxed for localhost):"
        echo "   - security.mixed_content.block_active_content = false"
        echo "   - security.mixed_content.block_display_content = false"
        echo ""
        echo "4. Install recommended extensions:"
        echo "   - React Developer Tools"
        echo "   - Vue.js devtools"
        echo "   - Web Developer"
        echo "   - Wappalyzer"
        echo "   - JSONView"
        echo "   - uBlock Origin"
        echo ""
        echo "5. Create a separate development profile:"
        echo "   firefox-devedition -ProfileManager"
        echo ""
      '';
      executable = true;
    };
  };
}
