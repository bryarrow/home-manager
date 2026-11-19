{ pkgs, lib, ... }:

# 留作模板
# let
#   chinese-calendar = pkgs.stdenvNoCC.mkDerivation {
#     pname = "gnome-shell-extension-chinese-calendar";
#     version = "1.8";

#     src = pkgs.fetchurl {
#       url = "https://extensions.gnome.org/review/download/76340.shell-extension.zip";
#       hash = "sha256-FwshcpXncZpPIVzTzKZ7EnuFLohpY0Qy+QUr/CEzKho=";
#     };

#     nativeBuildInputs = [
#       pkgs.glib
#       pkgs.unzip
#     ];

#     dontUnpack = true;

#     installPhase = ''
#       runHook preInstall
#       extension_dir=$out/share/gnome-shell/extensions/chinese-calendar@tigertall
#       mkdir -p "$extension_dir"
#       unzip -q "$src" -d "$extension_dir"
#       glib-compile-schemas --strict "$extension_dir/schemas"
#       runHook postInstall
#     '';

#     meta = {
#       description = "Chinese lunar calendar, solar terms, festivals, and holidays for GNOME Shell";
#       homepage = "https://github.com/tigertall/chinese-calendar";
#       license = pkgs.lib.licenses.mit;
#       platforms = pkgs.lib.platforms.linux;
#     };
#   };
# in
{
  # home.file.".local/share/gnome-shell/extensions/chinese-calendar@tigertall".source =
  #   "${chinese-calendar}/share/gnome-shell/extensions/chinese-calendar@tigertall";

  home.packages = with pkgs; [
    gnomeExtensions.caffeine
    gnomeExtensions.compiz-alike-magic-lamp-effect
    gnomeExtensions.dock-window-preview
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.chinese-calendar
  ];
}
