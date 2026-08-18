{ pkgs, lib, ... }:

let
  chinese-calendar = pkgs.stdenvNoCC.mkDerivation {
    pname = "gnome-shell-extension-chinese-calendar";
    version = "1.4";

    src = pkgs.fetchurl {
      url = "https://extensions.gnome.org/review/download/72122.shell-extension.zip";
      hash = "sha256-qOlYzt1ePvmP4vlW1DFpJyNZd2ilaw3e02jmYVgXfTo=";
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

  blur-my-shell-head = pkgs.gnomeExtensions.blur-my-shell.overrideAttrs (old: {
    version = "unstable-2026-07-29";

    src = pkgs.fetchFromGitHub {
      owner = "aunetx";
      repo = "blur-my-shell";
      rev = "36ea91536e77b94a729053cf2849be6b53c8d50b";
      hash = "sha256-f+iVw6QLzmd7TdQU62JDywE2BJcJf0B3x7eB1Xix9Vs=";
    };

    nativeBuildInputs = old.nativeBuildInputs ++ [
      pkgs.gnome-shell
      pkgs.unzip
    ];

    buildPhase = ''
      runHook preBuild
      make build
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/gnome-shell/extensions/blur-my-shell@aunetx
      unzip -q build/blur-my-shell@aunetx.shell-extension.zip \
        -d $out/share/gnome-shell/extensions/blur-my-shell@aunetx
      glib-compile-schemas --strict \
        $out/share/gnome-shell/extensions/blur-my-shell@aunetx/schemas
      runHook postInstall
    '';
  });
in

{
  home.file.".local/share/gnome-shell/extensions/chinese-calendar@tigertall".source =
    "${chinese-calendar}/share/gnome-shell/extensions/chinese-calendar@tigertall";

  home.file.".local/share/gnome-shell/extensions/clipboard-indicator@tudmotu.com".source =
    "${clipboard-indicator}/share/gnome-shell/extensions/clipboard-indicator@tudmotu.com";

  home.file.".local/share/gnome-shell/extensions/blur-my-shell@aunetx".source =
    "${blur-my-shell-head}/share/gnome-shell/extensions/blur-my-shell@aunetx";
  
  home.packages = with pkgs; [
    gnomeExtensions.caffeine
  ];
}
