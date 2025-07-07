{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf mkOption types;
  
  cfg = config.services.openssh;
  
in {
  options.services.openssh = {
    enable = mkEnableOption "OpenSSH server";
    
    authorizedKeys = mkOption {
      type = with types; listOf str;
      default = [];
      description = ''
        A list of public SSH keys that will be added to the
        `authorized_keys` file for the root user. Each key should be in the
        format "<type> <key> <comment>", e.g.,
        "ssh-rsa AAAAB3NzaC1yc2E... user@example.com".
      '';
      example = [
        "ssh-rsa AAAAB3NzaC1yc2E... user@example.com"
        "ssh-ed25519 AAAAC3NzaC1lZ... user@work"
      ];
    };
    
    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = ''
        Additional configuration text appended to the end of the
        sshd_config file. This can be used to add configuration options
        not explicitly supported by this module.
      '';
      example = ''
        Match User admin
          X11Forwarding yes
        Match all
      '';
    };
    
    ports = mkOption {
      type = with types; listOf port;
      default = [ 22 ];
      description = ''
        The TCP ports on which the SSH daemon should listen for connections.
        The default is port 22, but you might want to run on a non-standard port
        to reduce automated login attempts.
      '';
      example = [ 22 2222 ];
    };
    
    permitRootLogin = mkOption {
      type = types.enum [ "yes" "without-password" "prohibit-password" "no" ];
      default = "no";
      description = ''
        Whether the root user can log in using SSH. Possible values:
        - "yes": Root login with password is allowed
        - "without-password" or "prohibit-password": Root login only with public key authentication
        - "no": Root login is not allowed (most secure)
      '';
    };
    
    passwordAuthentication = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to allow password-based authentication. It's recommended to
        keep this disabled and use public key authentication instead for
        better security.
      '';
    };
    
    pubkeyAuthentication = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether to allow public key authentication. This is the recommended
        method of authentication as it provides better security than
        password-based authentication.
      '';
    };
  };

  config = mkIf cfg.enable {
    # Enable and configure the OpenSSH service
    services.openssh = {
      enable = true;
      
      # Configure the ports to listen on
      # These are the TCP ports where the SSH daemon will accept connections
      ports = cfg.ports;
      
      # SSH daemon configuration settings
      settings = {
        # Authentication settings
        PasswordAuthentication = cfg.passwordAuthentication;
        PermitRootLogin = cfg.permitRootLogin;
        PubkeyAuthentication = cfg.pubkeyAuthentication;
        
        # Security best practices
        X11Forwarding = false;  # Disable X11 forwarding by default for security
        UsePAM = true;          # Enable Pluggable Authentication Modules
        PrintMotd = false;      # Don't print message of the day on login
        
        # Performance optimizations
        UseDns = false;         # Disable DNS lookups for faster connections
        TCPKeepAlive = true;    # Enable TCP keepalive messages
        ClientAliveInterval = 300;  # Seconds between keepalive messages
        ClientAliveCountMax = 3;    # Number of keepalive messages before disconnecting
      };
      
      # Append any additional configuration provided by the user
      extraConfig = cfg.extraConfig;
      
      # Configure authorized keys file location if keys are provided
      authorizedKeysFiles = if cfg.authorizedKeys != [] then 
        [ "/etc/ssh/authorized_keys.d/%u" ]  # %u will be replaced with the username
      else 
        null;  # Use default location if no keys specified
    };
    
    # Set up authorized keys for the root user if any are provided
    # This creates /etc/ssh/authorized_keys.d/root with the specified public keys
    environment.etc = lib.optionalAttrs (cfg.authorizedKeys != []) {
      "ssh/authorized_keys.d/root" = {
        text = builtins.concatStringsSep "\n" cfg.authorizedKeys;
        mode = "0600";  # Restrict permissions to owner read/write only
      };
    };
  };
}