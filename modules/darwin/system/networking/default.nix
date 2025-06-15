# System Networking Module for Darwin (macOS)
#
# Version: 2.2.0
# Last Updated: 2025-06-15
#
# A networking configuration system for Darwin systems.
# Provides DNS and firewall configuration.
{ config, lib, ... }:

with lib;

let
  # Default DNS servers (Cloudflare)
  defaultDNSServers = [
    "1.1.1.1"     # Cloudflare Primary
    "1.0.0.1"     # Cloudflare Secondary
    "2606:4700:4700::1111"  # Cloudflare Primary (IPv6)
    "2606:4700:4700::1001"  # Cloudflare Secondary (IPv6)
  ];

  # Default firewall settings
  defaultFirewallSettings = {
    globalstate = 1; # 1 = enabled
    loggingenabled = 0; # Disable logging by default
    stealthenabled = 0; # Disable stealth mode by default
  };

  # Type definitions
  dnsServerType = types.listOf types.str;
  firewallStateType = types.enum [ 0 1 2 ];

in {
  options.system.networking = {
    # DNS Configuration
    dns = {
      servers = mkOption {
        type = dnsServerType;
        default = defaultDNSServers;
        description = "List of DNS servers to use";
      };
    };

    # Firewall Configuration
    firewall = {
      globalState = mkOption {
        type = firewallStateType;
        default = defaultFirewallSettings.globalstate;
        description = "Firewall state (0=disabled, 1=enabled, 2=block all)";
      };
      enableLogging = mkOption {
        type = types.bool;
        default = defaultFirewallSettings.loggingenabled == 1;
        description = "Whether to enable firewall logging";
      };
      enableStealthMode = mkOption {
        type = types.bool;
        default = defaultFirewallSettings.stealthenabled == 1;
        description = "Enable stealth mode (don't respond to ICMP pings)";
      };
    };
  };

  config = {
    # Apply network services configuration
    networking.knownNetworkServices = [ "Wi-Fi" "Ethernet" ];

    # Apply DNS configuration
    networking.dns = config.system.networking.dns.servers;

    # Apply firewall configuration
    system.defaults.alf = {
      globalstate = if config.system.networking.firewall.globalState == 1 then 1 else 0;
      loggingenabled = if config.system.networking.firewall.enableLogging then 1 else 0;
      stealthenabled = if config.system.networking.firewall.enableStealthMode then 1 else 0;
    };
  };
}
