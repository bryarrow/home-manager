{ pkgs, lib, ... }:

let
  chinese-calendar = pkgs.stdenvNoCC.mkDerivation {
    pname = "gnome-shell-extension-chinese-calendar";
    version = "1.8";

    src = pkgs.fetchurl {
      url = "https://extensions.gnome.org/review/download/76340.shell-extension.zip";
      hash = "sha256-FwshcpXncZpPIVzTzKZ7EnuFLohpY0Qy+QUr/CEzKho=";
    };

    nativeBuildInputs = [
      pkgs.glib
      pkgs.unzip
    ];

    dontUnpack = true;

    installPhase = ''
      runHook preInstall
      extension_dir=$out/share/gnome-shell/extensions/chinese-calendar@tigertall
      mkdir -p "$extension_dir"
      unzip -q "$src" -d "$extension_dir"
      glib-compile-schemas --strict "$extension_dir/schemas"
      runHook postInstall
    '';

    meta = {
      description = "Chinese lunar calendar, solar terms, festivals, and holidays for GNOME Shell";
      homepage = "https://github.com/tigertall/chinese-calendar";
      license = pkgs.lib.licenses.mit;
      platforms = pkgs.lib.platforms.linux;
    };
  };

  clipboard-indicator = pkgs.stdenvNoCC.mkDerivation {
    pname = "gnome-shell-extension-clipboard-indicator";
    version = "71";

    src = pkgs.fetchurl {
      url = "https://extensions.gnome.org/review/download/70694.shell-extension.zip";
      hash = "sha256-aHy0BPlUCVjdsMHeY4lwVyzvc/IvAW5dbG1vXUzVX5c=";
    };

    nativeBuildInputs = [
      pkgs.glib
      pkgs.unzip
    ];

    dontUnpack = true;

    installPhase = ''
      runHook preInstall
      extension_dir=$out/share/gnome-shell/extensions/clipboard-indicator@tudmotu.com
      mkdir -p "$extension_dir"
      unzip -q "$src" -d "$extension_dir"
      glib-compile-schemas --strict "$extension_dir/schemas"
      runHook postInstall
    '';

    meta = {
      description = "The most popular clipboard manager for GNOME, with over 1M downloads";
      homepage = "https://github.com/Tudmotu/gnome-shell-extension-clipboard-indicator";
      license = pkgs.lib.licenses.mit;
      platforms = pkgs.lib.platforms.linux;
    };
  };
in

{
  home.file.".local/share/gnome-shell/extensions/chinese-calendar@tigertall".source =
    "${chinese-calendar}/share/gnome-shell/extensions/chinese-calendar@tigertall";

  home.file.".local/share/gnome-shell/extensions/clipboard-indicator@tudmotu.com".source =
    "${clipboard-indicator}/share/gnome-shell/extensions/clipboard-indicator@tudmotu.com";
  
  home.packages = with pkgs; [
    gnomeExtensions.caffeine
    gnomeExtensions.compiz-alike-magic-lamp-effect
  ];
}
