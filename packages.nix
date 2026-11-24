{ pkgs, lib, ... }:

let
  hm-apps = pkgs.callPackage ./pkgs/hm-apps/package.nix { };
  hm-sync-dconf = pkgs.callPackage ./pkgs/hm-sync-dconf/package.nix { };
  dsh = pkgs.callPackage ./pkgs/dsh/package.nix { };
in

{
  # 用户级软件放这里；系统服务、驱动和桌面环境仍放在 /etc/nixos。

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "google-chrome"
    "code"
    "vscode"
  ];
  
  programs.vscode = {
    enable = true;
    package = pkgs.vscode.fhs;
  };

  home.packages = with pkgs; [
    dconf-editor
    deepseek-harness
    ghostty
    github-cli
    glmark2
    google-chrome
    gparted
    hm-apps
    hm-sync-dconf
    mission-center
    prismlauncher
    resources
    telegram-desktop
    vkmark
    yazi
  ];
}
