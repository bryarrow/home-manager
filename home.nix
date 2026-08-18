{ ... }:

{
  imports = [
    ./gnome-dconf.nix
    ./gnome-extensions.nix
    ./gtk3-themes.nix
    ./qt-themes.nix
    ./fonts.nix
    ./packages.nix
  ];

  home.username = "berry";
  home.homeDirectory = "/home/berry";

  # 这是 Home Manager 首次接管用户环境时的版本，用来保持用户配置兼容。
  # 启用后不要随意跟随系统升级修改。
  home.stateVersion = "26.11";

  programs.home-manager.enable = true;
}
