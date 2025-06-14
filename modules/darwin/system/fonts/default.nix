{ config, lib, pkgs, ... }:

with lib;

let
  # Font package collections following Interface Segregation Principle
  # Each collection has a single responsibility
  fontCollections = {
    # System fonts - basic fonts that should be available on all systems
    system = with pkgs; [
      corefonts  # MS fonts
      b612        # High legibility
      source-sans
      inter
      lexend
      monaspace   # Modern monospace font
    ];

    # UI/Icon fonts - for applications and UI elements
    ui = with pkgs; [
      material-icons
      material-design-icons
      work-sans
      comic-neue
    ];

    # Emoji fonts - for emoji support
    emoji = with pkgs; [
      noto-fonts-color-emoji
      noto-fonts-monochrome-emoji
    ];

    # Developer fonts - monospace fonts for coding
    developer = with pkgs; [
      nerd-fonts.fira-code
      nerd-fonts.hack
      nerd-fonts.sauce-code-pro
      nerd-fonts.symbols-only
      cascadia-code  # Modern monospace font
    ];
  };
  
  # Default font settings
  defaultFont = "MonaspaceNe";

  # Default font collections to enable
  defaultEnabledCollections = [ "system" "ui" "emoji" "developer" ];

  # Darwin-specific font configuration
  cfg = config.system.fonts;

  # Helper function to get enabled font packages
  getEnabledFontPackages = collections: 
    let
      # Filter out non-existent collections
      validCollections = filter (name: hasAttr name fontCollections) collections;
    in
      concatMap (name: getAttr name fontCollections) validCollections;

in {
  options.system = {
    fonts = {
      enable = mkEnableOption "system font configuration";
      
      # Default font name
      default = mkOption {
        type = types.str;
        default = defaultFont;
        description = "Default system font name";
        example = "MonaspaceNe";
      };

      # Font collections to enable (system, ui, emoji, developer)
      collections = mkOption {
        type = with types; listOf str;
        default = defaultEnabledCollections;
        description = ''
          List of font collections to enable. Available collections:
          - system: Basic system fonts
          - ui: UI and icon fonts
          - emoji: Emoji fonts
          - developer: Developer/monospace fonts
        '';
        example = literalExpression ''[ "system" "developer" ]'';
      };
      
      # Allow users to specify additional font packages to install
      extraPackages = mkOption {
        type = with types; listOf package;
        default = [];
        description = "Additional font packages to install";
        example = literalExpression "[ pkgs.fira-code ]";
      };
      
      # Font smoothing configuration (Darwin-specific)
      smoothing = {
        enable = mkEnableOption "font smoothing" // {
          default = true;
        };
        
        # AppleFontSmoothing values:
        # 0: No smoothing (crisp)
        # 1: Light smoothing (default)
        # 2: Medium smoothing
        # 3: Strong smoothing
        level = mkOption {
          type = types.ints.between 0 3;
          default = 1;
          description = ''
            Font smoothing level (0-3):
            0 = No smoothing (crisp)
            1 = Light smoothing (default)
            2 = Medium smoothing
            3 = Strong smoothing
          '';
        };
      };
    };
  };
  
  config = mkIf cfg.enable (mkMerge [
    {
      # Install the specified font packages
      fonts.packages = 
        # Get enabled font collections
        (getEnabledFontPackages cfg.collections) 
        # Add any extra packages
        ++ cfg.extraPackages;
      
      # Enable icons in tooling
      environment.variables = {
        LOG_ICONS = "true";
        # Set default font for applications that respect XDG spec
        XDG_DEFAULT_FONT = cfg.default;
      };
      
      # Set font smoothing defaults if enabled
      system.defaults.NSGlobalDomain = mkIf cfg.smoothing.enable {
        AppleFontSmoothing = cfg.smoothing.level;
      };
      
      # Require primaryUser to be set if using font smoothing
      assertions = optionals cfg.smoothing.enable [
        {
          assertion = config.system.primaryUser != null;
          message = ''
            The option `system.fonts.smoothing.enable` requires `system.primaryUser` to be set.
            Please set `system.primaryUser` to the name of the primary user.
          '';
        }
      ];
    }
  ]);
}
