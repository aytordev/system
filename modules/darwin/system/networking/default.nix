{
  config,
  lib,
  ...
}:
with lib; let
  defaultDNSServers = [
    "1.1.1.1"
    "1.0.0.1"
    "2606:4700:4700::1111"
    "2606:4700:4700::1001"
  ];
  dnsServerType = types.listOf (types.strMatching "^[0-9a-fA-F:.]+$");
  hostnameType = types.strMatching "^[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?$";
in {
  options.system.networking = {
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
    dns = {
      servers = mkOption {
        type = dnsServerType;
        default = defaultDNSServers;
        description = "List of DNS servers to use";
      };
    };
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
    networking.knownNetworkServices = ["Wi-Fi" "Ethernet"];
    networking.computerName = mkIf (config.system.networking.computerName != null) config.system.networking.computerName;
    networking.hostName = mkIf (config.system.networking.hostName != null) config.system.networking.hostName;
    networking.localHostName = mkIf (config.system.networking.localHostName != null) config.system.networking.localHostName;
    networking.dns = config.system.networking.dns.servers;
    networking.applicationFirewall = {
      enable = config.system.networking.firewall.enable;
      blockAllIncoming = config.system.networking.firewall.blockAllIncoming;
      enableStealthMode = config.system.networking.firewall.enableStealthMode;
    };
  };
}
