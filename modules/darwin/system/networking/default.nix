# System Networking Module for Darwin (macOS)
#
# Version: 3.0.0
# Last Updated: 2025-06-27
#
# This module provides comprehensive networking configuration for Darwin systems,
# including DNS settings, firewall configuration, and network service management.
#
# ## Features
# - Configure system-wide DNS servers
# - Modern application firewall configuration
# - Network service management
# - Network time synchronization
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
#       enable = true;  # Enable the firewall
#       blockAllIncoming = false;  # Block all incoming connections when true
#       enableStealthMode = false;  # Enable stealth mode (no ICMP responses)
#       allowedTCPPorts = [80 443];  # Allowed TCP ports
#       allowedUDPPorts = [53 123];  # Allowed UDP ports
#     };
#
#     # Network time synchronization
#     timeServer = "time.apple.com";
#   };
# }
# ```
{
  config,
  lib,
  ...
}:
with lib; let
  # Default DNS servers (Cloudflare)
  #
  # These are the default DNS servers that will be used if none are specified.
  # Cloudflare's DNS is used by default for its privacy-focused approach and performance.
  defaultDNSServers = [
    "1.1.1.1" # Cloudflare Primary
    "1.0.0.1" # Cloudflare Secondary
    "2606:4700:4700::1111" # Cloudflare Primary (IPv6)
    "2606:4700:4700::1001" # Cloudflare Secondary (IPv6)
  ];

  # Type definitions for module options
  #
  # These types ensure type safety and provide documentation for the module's options.
  dnsServerType = types.listOf (types.strMatching "^[0-9a-fA-F:.]+$");

  # Hostname validation regex (RFC 1123)
  hostnameType = types.strMatching "^[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?$";
in {
  # Main module options
  #
  # These options are available under `system.networking` in the system configuration.
  options.system.networking = {
    # Host Identification
    #
    # Configure system identification and naming.
    hostName = mkOption {
      type = types.nullOr hostnameType;
      default = null;
      description = "The hostname of the system (e.g., 'my-macbook')";
    };

    computerName = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "User-friendly computer name (e.g., 'My MacBook')";
    };

    localHostName = mkOption {
      type = types.nullOr hostnameType;
      default = null;
      description = "Local (Bonjour) hostname (e.g., 'My-MacBook')";
    };

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
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable the application firewall";
      };
      blockAllIncoming = mkOption {
        type = types.bool;
        default = false;
        description = "Block all incoming connections";
      };
      enableStealthMode = mkOption {
        type = types.bool;
        default = false;
        description = "Enable stealth mode (don't respond to ICMP pings)";
      };
    };
  };

  config = {
    # Apply network services configuration
    networking.knownNetworkServices = ["Wi-Fi" "Ethernet"];

    # Set host identification if specified
    networking.computerName = mkIf (config.system.networking.computerName != null) config.system.networking.computerName;
    networking.hostName = mkIf (config.system.networking.hostName != null) config.system.networking.hostName;
    networking.localHostName = mkIf (config.system.networking.localHostName != null) config.system.networking.localHostName;

    # Apply DNS configuration
    networking.dns = config.system.networking.dns.servers;

      # Apply firewall configuration
      networking.applicationFirewall = {
        enable = config.system.networking.firewall.enable;
        blockAllIncoming = config.system.networking.firewall.blockAllIncoming;
        enableStealthMode = config.system.networking.firewall.enableStealthMode;
        # Logging is controlled by the system log level
      };

      # Note: Port-based firewall rules are not supported on Darwin
      # Use application-level firewall rules or pf for advanced filtering
  };
}
