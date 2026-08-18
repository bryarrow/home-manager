{ pkgs, ... }:

{
  home.packages = with pkgs; [
    adw-gtk3
    gnomeExtensions.adw-gtk3-colorizer
  ];
}