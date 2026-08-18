{ fonts, pkgs, ... }:

{
  home.packages = with pkgs; [
    dejavu_fonts
    liberation_ttf
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    source-han-sans
    source-han-serif
    source-han-mono
    maple-mono.NF-CN
  ];

  fonts.fontconfig = {
    enable = true;
    hinting = "full";

    defaultFonts = {
      sansSerif = [
        "Noto Sans CJK SC"
        "Noto Sans"
        "DejaVu Sans"
      ];

      serif = [
        "Noto Serif CJK SC"
        "Noto Serif"
        "DejaVu Serif"
      ];

      monospace = [
        "Maple Mono NF CN"
        "Noto Sans Mono CJK SC"
        "Noto Sans Mono"
        "DejaVu Sans Mono"
      ];
    };
  };
}
