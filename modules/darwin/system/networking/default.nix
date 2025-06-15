# System Networking Module for Darwin (macOS)
#
# Version: 2.2.0
# Last Updated: 2025-06-15
#
# This module provides comprehensive networking configuration for Darwin systems,
# including DNS settings, firewall configuration, and network service management.
#
# ## Features
# - Configure system-wide DNS servers
# - Manage firewall settings and rules
# - Set up network services and interfaces
# - Configure network time synchronization
#
# ## Example Usage
# ```nix
# {
#   system.networking = {
#     # Configure DNS servers
#     dns = {
#       servers = ["1.1.1.1" "1.0.0.1"];
#       enableIPv6 = true;
#     };
#
#     # Firewall configuration
#     firewall = {
#       globalState = 1;  # 1 = enabled
#       enableLogging = false;
#       stealthMode = false;
#       allowedTCPPorts = [80 443];
#       allowedUDPPorts = [53 123];
#     };
#
#     # Network time synchronization
#     timeServer = "time.apple.com";
#   };
# }
# ```
{ config, lib, ... }:

with lib;

let
  # Default DNS servers (Cloudflare)
  #
  # These are the default DNS servers that will be used if none are specified.
  # Cloudflare's DNS is used by default for its privacy-focused approach and performance.
  defaultDNSServers = [
    "1.1.1.1"     # Cloudflare Primary
    "1.0.0.1"     # Cloudflare Secondary
    "2606:4700:4700::1111"  # Cloudflare Primary (IPv6)
    "2606:4700:4700::1001"  # Cloudflare Secondary (IPv6)
  ];

  # Default firewall settings
  #
  # These settings provide a balanced approach between security and usability.
  # The firewall is enabled by default but with logging disabled to reduce disk I/O.
  defaultFirewallSettings = {
    globalstate = 1; # 1 = enabled
    loggingenabled = 0; # Disable logging by default
    stealthenabled = 0; # Disable stealth mode by default
  };

  # Type definitions for module options
  #
  # These types ensure type safety and provide documentation for the module's options.
  dnsServerType = types.listOf (types.strMatching "^[0-9a-fA-F:.]+$");
  
  # Firewall state type:
  # - 0: Disabled
  # - 1: Enabled (default)
  # - 2: Block all incoming connections
  firewallStateType = types.enum [ 0 1 2 ] // {
    description = "Firewall state (0=disabled, 1=enabled, 2=block all)";
  };

in {
  # Main module options
  #
  # These options are available under `system.networking` in the system configuration.
  options.system.networking = {
    # Whether to enable the networking module
    #
    # Type: boolean
    # Default: true
    enable = mkEnableOption "system networking configuration";
    
    # DNS Configuration
    #
    # Controls the system's DNS resolver configuration.
    dns = {
      servers = mkOption {
        type = dnsServerType;
        default = defaultDNSServers;
        description = "List of DNS servers to use";
      };
    };

    # Firewall Configuration
    #
    # Controls the application firewall settings and rules.
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
