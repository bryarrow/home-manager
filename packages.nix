{ pkgs, lib, ... }:

let
  hm-apps = pkgs.callPackage ./pkgs/hm-apps/package.nix { };
  hm-sync-dconf = pkgs.callPackage ./pkgs/hm-sync-dconf/package.nix { };
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
    codex
    dconf-editor
    ghostty
    google-chrome
    hm-apps
    hm-sync-dconf
    hmcl
    opencode
    telegram-desktop
    yazi



  ];
}
