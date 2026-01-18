{
  # Helper to transform hex #RRGGBB to 0xffRRGGBB
  # But since this is a pure data file, we'll store them as raw strings and rely on consumers to format,
  # OR format them here manually. formatting here manually is safer for Lua consumption.

  # Palette Definitions
  schemes = {
    wave = {
      default = "0xffdcd7ba"; # fujiWhite
      black = "0xff16161d";   # sumiInk0
      white = "0xffdcd7ba";   # fujiWhite
      red = "0xffc34043";     # autumnRed
      red_bright = "0xffe82424"; # samuraiRed
      green = "0xff76946a";   # autumnGreen
      blue = "0xff7e9cd8";    # crystalBlue
      blue_bright = "0xff7fb4ca"; # springBlue
      yellow = "0xffc0a36e";  # boatYellow2
      orange = "0xffff9e3b";  # roninYellow
      magenta = "0xff957fb8"; # oniViolet
      grey = "0xff727169";    # fujiGray
      transparent = "0x00000000";

      bar = {
        bg = "0xf01f1f28";    # sumiInk3 with alpha
        border = "0xff2a2a37"; # sumiInk4
      };

      popup = {
        bg = "0xff1f1f28";    # sumiInk3
        border = "0xff2a2a37"; # sumiInk4
      };

      bg1 = "0xff1f1f28";     # sumiInk3
      bg2 = "0xff2a2a37";     # sumiInk4

      accent = "0xff7e9cd8";  # crystalBlue (or oniViolet 0xff957fb8)
      accent_bright = "0xffbc96da"; # springViolet1 (approx)

      spotify_green = "0xff76946a"; # autumnGreen
    };

    dragon = {
      default = "0xffc5c9c5"; # dragonWhite
      black = "0xff0d0c0c";   # dragonBlack0
      white = "0xffc5c9c5";   # dragonWhite
      red = "0xffc4746e";     # dragonRed
      red_bright = "0xffe46876"; # waveRed
      green = "0xff87a987";   # dragonGreen
      blue = "0xff8ba4b0";    # dragonBlue2
      blue_bright = "0xff7fb4ca"; # springBlue
      yellow = "0xffc4b28a";  # dragonYellow
      orange = "0xffb6927b";  # dragonOrange
      magenta = "0xffa292a3"; # dragonPink
      grey = "0xffa6a69c";    # dragonGray
      transparent = "0x00000000";

      bar = {
        bg = "0xf0181616";    # dragonBlack3 with alpha
        border = "0xff282727"; # dragonBlack4
      };

      popup = {
        bg = "0xff181616";    # dragonBlack3
        border = "0xff282727"; # dragonBlack4
      };

      bg1 = "0xff181616";     # dragonBlack3
      bg2 = "0xff282727";     # dragonBlack4

      accent = "0xff8ba4b0";  # dragonBlue2
      accent_bright = "0xff8992a7"; # dragonViolet

      spotify_green = "0xff87a987"; # dragonGreen
    };

    lotus = {
      default = "0xff545464"; # lotusInk1
      black = "0xffdcd7ba";   # lotusGray (inverted-ish logic for light theme) -> using lotusInk1 for text usually
      white = "0xff545464";   # lotusInk1 (Main Text)
      red = "0xffc84053";     # lotusRed
      red_bright = "0xffe82424"; # lotusRed3
      green = "0xff6f894e";   # lotusGreen
      blue = "0xff4d699b";    # lotusBlue4
      blue_bright = "0xff5d57a3"; # lotusBlue5
      yellow = "0xff77713f";  # lotusYellow
      orange = "0xffcc6d00";  # lotusOrange
      magenta = "0xffa09cac"; # lotusViolet1
      grey = "0xff8a8980";    # lotusGray3
      transparent = "0x00000000";

      bar = {
        bg = "0xf0f2ecbc";    # lotusWhite3 with alpha
        border = "0xffe7dba0"; # lotusWhite4
      };

      popup = {
        bg = "0xfff2ecbc";    # lotusWhite3
        border = "0xffe7dba0"; # lotusWhite4
      };

      bg1 = "0xfff2ecbc";     # lotusWhite3
      bg2 = "0xffe7dba0";     # lotusWhite4

      accent = "0xff4d699b";  # lotusBlue4
      accent_bright = "0xff5d57a3"; # lotusBlue5

      spotify_green = "0xff6f894e"; # lotusGreen
    };
  };
}
