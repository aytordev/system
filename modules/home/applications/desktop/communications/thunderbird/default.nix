{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkOption types mkIf;
  
  cfg = config.programs.thunderbird;
  
  calendarType = types.submodule {
    options = {
      url = mkOption {
        type = types.str;
        description = "Calendar URL";
      };
      type = mkOption {
        type = types.enum [ "caldav" "http" ];
        description = "Calendar type";
      };
      color = mkOption {
        type = types.str;
        default = "#9a9cff";
        description = "Calendar display color";
      };
    };
  };

  emailAccountType = types.submodule {
    options = {
      address = mkOption {
        type = types.str;
        description = "Email address";
      };
      flavor = mkOption {
        type = types.enum [
          "plain"
          "gmail.com"
          "runbox.com"
          "fastmail.com"
          "yandex.com"
          "outlook.office365.com"
          "davmail"
          "protonmail.com"
          "icloud.com"
        ];
        description = "Email service provider";
      };
    };
  };

in {
  options.programs.thunderbird = {
    enable = mkEnableOption "Thunderbird email client";
    
    accountsOrder = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Custom ordering of email accounts";
    };

    calendarAccounts = mkOption {
      type = types.attrsOf calendarType;
      default = {};
      description = "Calendar accounts configuration";
      example = {
        "Work" = {
          url = "https://example.com/calendars/user/events/";
          type = "caldav";
          color = "#ff6b6b";
        };
      };
    };

    emailAccounts = mkOption {
      type = types.attrsOf emailAccountType;
      default = {};
      description = "Email accounts configuration";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; lib.optionals stdenv.hostPlatform.isLinux [ birdtray ];

    accounts.calendar.accounts = 
      let
        mkCalendarConfig = name: { url, type, color, ... }: {
          remote = { inherit url type; };
          local = { inherit color; };
          thunderbird = {
            enable = true;
            inherit color;
          };
        };
      in
        lib.mapAttrs mkCalendarConfig cfg.calendarAccounts;

    accounts.email.accounts = 
      let
        mkEmailConfig = _: { address, flavor, ... }: {
          inherit address;
          flavor = if flavor == "davmail" then "plain" else flavor;
          realName = config.home.username;
          userName = lib.mkIf (flavor == "davmail") address;
          imap = lib.mkIf (flavor == "davmail") {
            host = "localhost";
            port = 1143;
            tls.enable = false;
          };
          smtp = lib.mkIf (flavor == "davmail") {
            host = "localhost";
            port = 1025;
            tls.enable = false;
          };
          thunderbird = {
            enable = true;
            settings = _: {};
          };
        };
      in
        lib.mapAttrs mkEmailConfig cfg.emailAccounts;

    programs.thunderbird = {
      enable = true;
      package = pkgs.thunderbird-latest;
      profiles.${config.home.username} = {
        isDefault = true;
        inherit (cfg) accountsOrder;
        settings = {
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          "layers.acceleration.force-enabled" = true;
          "gfx.webrender.all" = true;
          "gfx.webrender.enabled" = true;
          "svg.context-properties.content.enabled" = true;
          "browser.display.use_system_colors" = true;
          "browser.theme.dark-toolbar-theme" = true;
          "mailnews.default_sort_type" = 18;
          "mailnews.default_sort_order" = 2;
        };
        userChrome = ''
          #spacesToolbar,
          #agenda-container,
          #agenda,
          #agenda-toolbar,
          #mini-day-box {
            background-color: #24273a !important;
          }
        '';
      };
    };
  };
}
