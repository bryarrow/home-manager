{ pkgs, ... }:

{
  home.packages = [
    pkgs.adwaita-qt6
  ];

  qt = {
    enable = true;
    platformTheme.name = "adwaita";
    style = {
      name = "adwaita";
      package = pkgs.adwaita-qt;
    };
  };
}
